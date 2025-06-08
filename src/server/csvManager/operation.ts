import { HttpError } from "wasp/server"
import { z } from "zod"
import { parse } from "csv-parse/sync"

const uploadCsvInputSchema = z.object({
  batchName: z.string(),
  batchType: z.enum(["Company", "People"]),
  mapping: z.record(z.string(), z.string()),
  fileName: z.string(),
  originalName: z.string(),
  fileContent: z.string(),
})

const updateCellSchema = z.object({
  rowId: z.string(),
  columnKey: z.string(),
  value: z.string(),
})

export const uploadCsv = async (rawArgs: any, context: any) => {
  // Ensure user is authenticated
  if (!context.user) throw new HttpError(401)

  const { batchName, batchType, mapping, fileName, originalName, fileContent } = uploadCsvInputSchema.parse(rawArgs)

  try {
    // Parse CSV content
    const records = parse(fileContent, {
      columns: true,
      skipEmptyLines: true,
      trim: true,
    })

    if (records.length === 0) {
      throw new HttpError(400, "CSV file is empty or invalid")
    }

    // Ensure columnHeaders is always a string[] and contains only strings
    const columnHeaders = Object.keys(records[0] || {}).filter((h): h is string => typeof h === 'string')
    const rowCount = records.length

    // Apply field mapping to transform data
    const transformedRecords = records.map((row, idx) => {
      const transformedRow: Record<string, any> = {}

      // Apply mapping: system field -> CSV column
      Object.entries(mapping).forEach(([systemField, csvColumn]) => {
        if (csvColumn && csvColumn !== "-- Not Mapped --") {
          transformedRow[systemField] = row[csvColumn] || ""
        }
      })

      return {
        rowData: transformedRow,
        rowIndex: idx,
        originalData: row, // Keep original for reference
      }
    })

    // Validate required fields based on batch type
    if (batchType === "Company") {
      const hasCompanyName = transformedRecords.every(
        (record) => record.rowData["Company Name"] && record.rowData["Company Name"].trim() !== "",
      )
      if (!hasCompanyName) {
        throw new HttpError(400, "Company Name is required for all records")
      }
    }

    // Create CsvFile record with proper schema
    const csvFile = await context.entities.CsvFile.create({
      data: {
        userId: context.user.id,
        fileName,
        originalName,
        columnHeaders,
        rowCount,
        uploadedAt: new Date(),
        batchName, // REMOVE
        batchType, // REMOVE
        fieldMapping: mapping, // REMOVE
        rows: {
          create: transformedRecords.map((record) => ({
            rowData: record.rowData,
            rowIndex: record.rowIndex,
          })),
        },
      },
      include: {
        rows: {
          orderBy: { rowIndex: "asc" },
        },
      },
    })

    return {
      success: true,
      fileId: csvFile.id,
      recordsImported: rowCount,
      csvFile,
    }
  } catch (error) {
    console.error("CSV upload error:", error)

    if (error instanceof HttpError) {
      throw error
    }

    throw new HttpError(500, `Failed to process CSV: ${error.message}`)
  }
}

// New operation for updating cell values
export const updateCsvCell = async (rawArgs: any, context: any) => {
  if (!context.user) throw new HttpError(401)

  const { rowId, columnKey, value } = updateCellSchema.parse(rawArgs)

  try {
    // Get the row and verify ownership
    const row = await context.entities.CsvRow.findFirst({
      where: {
        id: rowId,
        csvFile: {
          userId: context.user.id,
        },
      },
    })

    if (!row) {
      throw new HttpError(404, "Row not found or access denied")
    }

    // Update the specific field in rowData
    const updatedRowData = {
      ...row.rowData,
      [columnKey]: value,
    }

    const updatedRow = await context.entities.CsvRow.update({
      where: { id: rowId },
      data: { rowData: updatedRowData },
    })

    return { success: true, updatedRow }
  } catch (error) {
    console.error("Cell update error:", error)
    if (error instanceof HttpError) {
      throw error
    }
    throw new HttpError(500, `Failed to update cell: ${error.message}`)
  }
}

// Additional operation for fetching user's CSV files
export const getUserCsvFiles = async (args: any, context: any) => {
  if (!context.user) throw new HttpError(401)

  const csvFiles = await context.entities.CsvFile.findMany({
    where: { userId: context.user.id },
    include: {
      _count: {
        select: { rows: true },
      },
    },
    orderBy: { uploadedAt: "desc" },
  })

  return csvFiles
}

// Operation for fetching CSV data with pagination
export const getCsvData = async (args: { fileId: string; page?: number; limit?: number }, context: any) => {
  if (!context.user) throw new HttpError(401)

  const { fileId, page = 1, limit = 50 } = args
  const skip = (page - 1) * limit

  // Verify file belongs to user
  const csvFile = await context.entities.CsvFile.findFirst({
    where: {
      id: fileId,
      userId: context.user.id,
    },
  })

  if (!csvFile) {
    throw new HttpError(404, "CSV file not found")
  }

  const rows = await context.entities.CsvRow.findMany({
    where: { csvFileId: fileId },
    orderBy: { rowIndex: "asc" },
    skip,
    take: limit,
  })

  // Compute insights
  const totalRows = rows.length
  const columnHeaders = csvFile.columnHeaders || []
  const insights: Record<string, any> = { totalRows, columns: {} }

  // Helper functions for type detection
  const isNumber = (val: string) => /^-?\d+(\.\d+)?$/.test(val)
  const isDate = (val: string) => !isNaN(Date.parse(val))
  const isEmail = (val: string) => /^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(val)

  for (const header of columnHeaders) {
    const values = rows.map(r => r.rowData?.[header] ?? '').filter(v => v !== '' && v !== undefined && v !== null)
    const sample = values.slice(0, 50)
    let type = 'text'
    if (sample.length > 0) {
      if (sample.every(isNumber)) type = 'number'
      else if (sample.every(isDate)) type = 'date'
      else if (sample.every(isEmail)) type = 'email'
    }
    const uniqueValues = Array.from(new Set(values))
    const valueCounts: Record<string, number> = {}
    for (const v of values) {
      valueCounts[v] = (valueCounts[v] || 0) + 1
    }
    let mostCommonValue: string | null | number = null
    let mostCommonCount = 0
    for (const [val, count] of Object.entries(valueCounts)) {
      if (count > mostCommonCount) {
        mostCommonValue = val
        mostCommonCount = count
      }
    }
    insights.columns[header] = {
      uniqueCount: uniqueValues.length,
      mostCommonValue,
      empty: values.length === 0,
      type,
    }
  }

  return {
    csvFile,
    rows,
    pagination: {
      page,
      limit,
      total: csvFile.rowCount,
      totalPages: Math.ceil(csvFile.rowCount / limit),
    },
    insights,
  }
}

// Action to delete a CSV file and its rows
export const deleteCsvFile = async (args: { fileId: string }, context: any) => {
  if (!context.user) throw new HttpError(401)
  const { fileId } = args

  // Check ownership
  const csvFile = await context.entities.CsvFile.findFirst({
    where: {
      id: fileId,
      userId: context.user.id,
    },
    include: { rows: true },
  })
  if (!csvFile) throw new HttpError(404, 'CSV file not found or access denied')

  // Delete all rows first (if not set to cascade)
  await context.entities.CsvRow.deleteMany({ where: { csvFileId: fileId } })
  // Delete the file
  await context.entities.CsvFile.delete({ where: { id: fileId } })

  return { success: true }
}
