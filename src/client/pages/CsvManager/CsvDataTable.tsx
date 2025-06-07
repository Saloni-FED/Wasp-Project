"use client"

import type React from "react"
import { useMemo, useState, useEffect } from "react"
import { useQuery, useAction, getCsvData, updateCsvCell } from "wasp/client/operations"
import {
  useReactTable,
  getCoreRowModel,
  getFilteredRowModel,
  getSortedRowModel,
  getPaginationRowModel,
  flexRender,
  type ColumnDef,
  type SortingState,
  type VisibilityState,
  type RowSelectionState,
} from "@tanstack/react-table"
import { Input } from "../../../components/ui/input"
import { Button } from "../../../components/ui/button"
import { Checkbox } from "../../../components/ui/checkbox"
import { DropdownMenu, DropdownMenuCheckboxItem, DropdownMenuContent, DropdownMenuTrigger } from "../../../components/ui/dropdown-menu"
import { ChevronDown, ChevronUp, ChevronsUpDown, Settings2, Trash2 } from "lucide-react"

// Enhanced Editable cell component with better data handling
const EditableCell = ({
  getValue,
  row,
  column,
  table,
}: {
  getValue: () => any
  row: any
  column: any
  table: any
}) => {
  const initialValue = getValue() || ""
  const [value, setValue] = useState(String(initialValue))
  const [editing, setEditing] = useState(false)
  const [saving, setSaving] = useState(false)

  const updateCellAction = useAction(updateCsvCell)

  // Update local value when the initial value changes
  useEffect(() => {
    setValue(String(initialValue))
  }, [initialValue])

  const onSave = async () => {
    if (value !== String(initialValue)) {
      setSaving(true)
      try {
        await updateCellAction({
          rowId: row.original.id,
          columnKey: column.id,
          value: value,
        })
        // Update the table data optimistically
        table.options.meta?.updateData(row.index, column.id, value)
      } catch (error) {
        console.error("Failed to save cell:", error)
        setValue(String(initialValue)) // Revert on error
      } finally {
        setSaving(false)
      }
    }
    setEditing(false)
  }

  const onCancel = () => {
    setValue(String(initialValue))
    setEditing(false)
  }

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === "Enter") {
      onSave()
    } else if (e.key === "Escape") {
      onCancel()
    }
  }

  return editing ? (
    <div className="flex items-center gap-1">
      <input
        value={value}
        onChange={(e) => setValue(e.target.value)}
        onKeyDown={handleKeyDown}
        autoFocus
        className="border px-2 py-1 rounded text-sm w-full"
        disabled={saving}
      />
      <Button size="sm" onClick={onSave} disabled={saving} className="h-6 px-2">
        {saving ? "..." : "✓"}
      </Button>
      <Button size="sm" variant="outline" onClick={onCancel} disabled={saving} className="h-6 px-2">
        ✕
      </Button>
    </div>
  ) : (
    <div
      tabIndex={0}
      onClick={() => setEditing(true)}
      onKeyDown={(e) => e.key === "Enter" && setEditing(true)}
      className="cursor-pointer min-h-[24px] p-1 hover:bg-gray-50 rounded"
    >
      {value || <span className="text-gray-400 italic">Empty</span>}
    </div>
  )
}

const CsvDataTable = ({ fileId }: { fileId: string }) => {
  const [page, setPage] = useState(1)
  const [globalFilter, setGlobalFilter] = useState("")
  const [sorting, setSorting] = useState<SortingState>([])
  const [columnVisibility, setColumnVisibility] = useState<VisibilityState>({})
  const [rowSelection, setRowSelection] = useState<RowSelectionState>({})
  const [data, setData] = useState<any[]>([])

  const {
    data: queryData,
    isLoading,
    error,
  } = useQuery(getCsvData, {
    fileId,
    page,
    limit: 20,
  })

  // Debug logging
  useEffect(() => {
    console.log("Query data:", queryData)
    if (queryData?.rows) {
      console.log("First row data:", queryData.rows[0])
      console.log("Column headers:", queryData.csvFile?.columnHeaders)
    }
  }, [queryData])

  // Update local data when query data changes with better data mapping
  useEffect(() => {
    if (queryData?.rows) {
      const transformedData = queryData.rows.map((row: any, index: number) => {
        // Create a flattened object with both row metadata and row data
        const flattenedRow = {
          id: row.id,
          rowIndex: row.rowIndex,
          csvFileId: row.csvFileId,
          // Spread the rowData to make columns accessible
          ...(row.rowData || {}),
        }

        console.log(`Row ${index}:`, flattenedRow)
        return flattenedRow
      })

      setData(transformedData)
    }
  }, [queryData])

  // Dynamic columns from CSV headers with enhanced features
  const columns = useMemo<ColumnDef<any>[]>(() => {
    if (!queryData?.csvFile?.columnHeaders) return []

    console.log("Creating columns for headers:", queryData.csvFile.columnHeaders)

    const dataColumns: ColumnDef<any>[] = queryData.csvFile.columnHeaders.map((header: string) => ({
      accessorKey: header,
      header: ({ column }) => (
        <div className="flex items-center gap-2">
          <Button
            variant="ghost"
            onClick={() => column.toggleSorting(column.getIsSorted() === "asc")}
            className="h-8 p-0 font-semibold hover:bg-transparent"
          >
            {header}
            {column.getIsSorted() === "asc" ? (
              <ChevronUp className="ml-2 h-4 w-4" />
            ) : column.getIsSorted() === "desc" ? (
              <ChevronDown className="ml-2 h-4 w-4" />
            ) : (
              <ChevronsUpDown className="ml-2 h-4 w-4" />
            )}
          </Button>
        </div>
      ),
      cell: EditableCell,
    }))

    // Add selection column at the beginning
    return [
      {
        id: "select",
        header: ({ table }) => (
          <Checkbox
            checked={table.getIsAllPageRowsSelected()}
            onCheckedChange={(value) => table.toggleAllPageRowsSelected(!!value)}
            aria-label="Select all"
          />
        ),
        cell: ({ row }) => (
          <Checkbox
            checked={row.getIsSelected()}
            onCheckedChange={(value) => row.toggleSelected(!!value)}
            aria-label="Select row"
          />
        ),
        enableSorting: false,
        enableHiding: false,
      },
      ...dataColumns,
    ]
  }, [queryData])

  const table = useReactTable({
    data,
    columns,
    state: {
      sorting,
      columnVisibility,
      rowSelection,
      globalFilter,
      pagination: { pageIndex: page - 1, pageSize: 20 },
    },
    enableRowSelection: true,
    onRowSelectionChange: setRowSelection,
    onSortingChange: setSorting,
    onColumnVisibilityChange: setColumnVisibility,
    onGlobalFilterChange: setGlobalFilter,
    getCoreRowModel: getCoreRowModel(),
    getFilteredRowModel: getFilteredRowModel(),
    getSortedRowModel: getSortedRowModel(),
    getPaginationRowModel: getPaginationRowModel(),
    manualPagination: true,
    pageCount: queryData?.pagination?.totalPages || 0,
    onPaginationChange: (updater) => {
      if (typeof updater === "function") {
        const newState = updater({ pageIndex: page - 1, pageSize: 20 })
        setPage(newState.pageIndex + 1)
      } else if (typeof updater === "object") {
        setPage((updater.pageIndex || 0) + 1)
      }
    },
    meta: {
      updateData: (rowIndex: number, columnId: string, value: any) => {
        setData((old) =>
          old.map((row, index) => {
            if (index === rowIndex) {
              return {
                ...row,
                [columnId]: value,
              }
            }
            return row
          }),
        )
      },
    },
  })

  const selectedRowCount = Object.keys(rowSelection).length

  if (isLoading) return <div className="p-4">Loading CSV data...</div>
  if (error) return <div className="text-red-500 p-4">Error: {error.message}</div>
  if (!queryData?.rows || queryData.rows.length === 0) {
    return <div className="p-4 text-gray-500">No data found in this CSV file.</div>
  }

  return (
    <div className="w-full space-y-4">
      {/* Debug info - remove in production */}
      <div className="text-xs text-gray-500 p-2 bg-gray-50 rounded">
        Debug: {data.length} rows loaded, {columns.length - 1} data columns
      </div>

      {/* Toolbar */}
      <div className="flex items-center justify-between">
        <div className="flex items-center space-x-2">
          <Input
            placeholder="Filter all columns..."
            value={globalFilter ?? ""}
            onChange={(e) => setGlobalFilter(e.target.value)}
            className="max-w-sm"
          />

          {/* Column visibility dropdown */}
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button variant="outline" className="ml-auto">
                <Settings2 className="mr-2 h-4 w-4" />
                Columns
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end">
              {table
                .getAllColumns()
                .filter((column) => column.getCanHide())
                .map((column) => {
                  return (
                    <DropdownMenuCheckboxItem
                      key={column.id}
                      className="capitalize"
                      checked={column.getIsVisible()}
                      onCheckedChange={(value) => column.toggleVisibility(!!value)}
                    >
                      {column.id}
                    </DropdownMenuCheckboxItem>
                  )
                })}
            </DropdownMenuContent>
          </DropdownMenu>
        </div>

        {/* Selection actions */}
        {/* {selectedRowCount > 0 && (
          <div className="flex items-center space-x-2">
            <span className="text-sm text-muted-foreground">{selectedRowCount} row(s) selected</span>
            <Button variant="outline" size="sm">
              <Trash2 className="mr-2 h-4 w-4" />
              Delete Selected
            </Button>
          </div>
        )} */}
      </div>

      {/* Table */}
      <div className="rounded-md border">
        <table className="w-full">
          <thead>
            {table.getHeaderGroups().map((headerGroup) => (
              <tr key={headerGroup.id} className="border-b">
                {headerGroup.headers.map((header) => (
                  <th key={header.id} className="px-4 py-3 text-left font-medium">
                    {header.isPlaceholder ? null : flexRender(header.column.columnDef.header, header.getContext())}
                  </th>
                ))}
              </tr>
            ))}
          </thead>
          <tbody>
            {table.getRowModel().rows?.length ? (
              table.getRowModel().rows.map((row) => (
                <tr key={row.id} className={`border-b hover:bg-muted/50 ${row.getIsSelected() ? "bg-muted" : ""}`}>
                  {row.getVisibleCells().map((cell) => (
                    <td key={cell.id} className="px-4 py-2">
                      {flexRender(cell.column.columnDef.cell, cell.getContext())}
                    </td>
                  ))}
                </tr>
              ))
            ) : (
              <tr>
                <td colSpan={columns.length} className="h-24 text-center">
                  No results found.
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>

      {/* Pagination */}
      <div className="flex items-center justify-between space-x-2 py-4">
        <div className="text-sm text-muted-foreground">
          Showing {(page - 1) * 20 + 1} to {Math.min(page * 20, queryData?.pagination?.total || 0)} of{" "}
          {queryData?.pagination?.total || 0} entries
        </div>
        <div className="flex items-center space-x-2">
          <Button variant="outline" size="sm" onClick={() => setPage(page - 1)} disabled={page === 1}>
            Previous
          </Button>
          <div className="flex items-center space-x-1">
            <span className="text-sm">Page</span>
            <span className="text-sm font-medium">{page}</span>
            <span className="text-sm">of</span>
            <span className="text-sm font-medium">{queryData?.pagination?.totalPages || 1}</span>
          </div>
          <Button
            variant="outline"
            size="sm"
            onClick={() => setPage(page + 1)}
            disabled={page === queryData?.pagination?.totalPages}
          >
            Next
          </Button>
        </div>
      </div>
    </div>
  )
}

export default CsvDataTable
