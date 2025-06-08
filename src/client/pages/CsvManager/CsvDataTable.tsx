"use client"

import type React from "react"
import { useMemo, useState, useEffect, useRef } from "react"
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
  type ColumnOrderState,
} from "@tanstack/react-table"
import { DndContext, closestCenter, PointerSensor, useSensor, useSensors, type DragEndEvent } from "@dnd-kit/core"
import { SortableContext, arrayMove, horizontalListSortingStrategy, useSortable } from "@dnd-kit/sortable"
import { CSS } from "@dnd-kit/utilities"
import { Input } from "../../../components/ui/input"
import { Button } from "../../../components/ui/button"
import { Checkbox } from "../../../components/ui/checkbox"
import {
  DropdownMenu,
  DropdownMenuCheckboxItem,
  DropdownMenuContent,
  DropdownMenuTrigger,
} from "../../../components/ui/dropdown-menu"
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
  const inputRef = useRef<HTMLInputElement>(null)

  const updateCellAction = useAction(updateCsvCell)

  // Update local value when the initial value changes
  useEffect(() => {
    setValue(String(initialValue))
  }, [initialValue])

  // Focus input when editing starts
  useEffect(() => {
    if (editing && inputRef.current) {
      inputRef.current.focus()
      inputRef.current.select()
    }
  }, [editing])

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
    } else if (e.key === "Tab") {
      // Allow normal tab navigation
      onSave()
    } else if (e.key === "ArrowDown" || e.key === "ArrowUp") {
      // Save and move focus to cell above/below
      onSave()
      // Let the default behavior handle the focus movement
    }
  }

  return editing ? (
    <div className="flex items-center gap-1 min-w-0">
      <input
        ref={inputRef}
        value={value}
        onChange={(e) => setValue(e.target.value)}
        onKeyDown={handleKeyDown}
        onBlur={onSave}
        className="border px-2 py-1 rounded text-sm w-full min-w-0 focus:ring-2 focus:ring-primary/20 focus:border-primary"
        disabled={saving}
      />
      <Button size="sm" onClick={onSave} disabled={saving} className="h-6 px-2 flex-shrink-0">
        {saving ? "..." : "✓"}
      </Button>
      <Button size="sm" variant="outline" onClick={onCancel} disabled={saving} className="h-6 px-2 flex-shrink-0">
        ✕
      </Button>
    </div>
  ) : (
    <div
      tabIndex={0}
      role="button"
      aria-label={`Edit cell ${column.id}`}
      onClick={() => setEditing(true)}
      onKeyDown={(e) => {
        if (e.key === "Enter" || e.key === " ") {
          e.preventDefault()
          setEditing(true)
        }
      }}
      className="cursor-pointer min-h-[24px] p-1 hover:bg-gray-50 rounded truncate focus:ring-2 focus:ring-primary/20 focus:outline-none"
      title={value}
    >
      {value || <span className="text-gray-400 italic">Empty</span>}
    </div>
  )
}

// Draggable column header component
const DraggableColumnHeader = ({
  header,
  table,
}: {
  header: any
  table: any
}) => {
  const { attributes, listeners, setNodeRef, transform, transition, isDragging } = useSortable({
    id: header.id,
  })

  const style = {
    transform: CSS.Transform.toString(transform),
    transition,
    opacity: isDragging ? 0.8 : 1,
    position: "relative" as const,
    cursor: "grab",
    touchAction: "none",
  }

  return (
    <div ref={setNodeRef} style={style} {...attributes} {...listeners} className="flex items-center gap-2 min-w-0">
      <Button
        variant="ghost"
        onClick={() => header.column.toggleSorting(header.column.getIsSorted() === "asc")}
        className="h-8 p-0 font-semibold hover:bg-transparent text-xs sm:text-sm truncate"
      >
        <span className="truncate">{header.column.id}</span>
        {header.column.getIsSorted() === "asc" ? (
          <ChevronUp className="ml-1 h-3 w-3 sm:h-4 sm:w-4 flex-shrink-0" />
        ) : header.column.getIsSorted() === "desc" ? (
          <ChevronDown className="ml-1 h-3 w-3 sm:h-4 sm:w-4 flex-shrink-0" />
        ) : (
          <ChevronsUpDown className="ml-1 h-3 w-3 sm:h-4 sm:w-4 flex-shrink-0" />
        )}
      </Button>
    </div>
  )
}

const CsvDataTable = ({ fileId }: { fileId: string }) => {
  const [page, setPage] = useState(1)
  const [globalFilter, setGlobalFilter] = useState("")
  const [sorting, setSorting] = useState<SortingState>([])
  const [columnVisibility, setColumnVisibility] = useState<VisibilityState>({})
  const [rowSelection, setRowSelection] = useState<RowSelectionState>({})
  const [columnOrder, setColumnOrder] = useState<ColumnOrderState>([])
  const [data, setData] = useState<any[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [advancedFilters, setAdvancedFilters] = useState<any[]>([])

  // Setup DnD sensors for pointer only (keyboard sensor removed to fix TS error)
  const sensors = useSensors(
    useSensor(PointerSensor, {
      activationConstraint: {
        distance: 8,
      },
    }),
  )

  const { data: queryData, error } = useQuery(getCsvData, {
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

  // Initialize column order when columns change
  useEffect(() => {
    if (queryData?.csvFile?.columnHeaders) {
      // Initialize column order with 'select' first, then all data columns
      const initialOrder = ["select", ...queryData.csvFile.columnHeaders]
      setColumnOrder(initialOrder)
      setIsLoading(false)
    }
  }, [queryData?.csvFile?.columnHeaders])

  // Dynamic columns from CSV headers with enhanced features
  const columns = useMemo<ColumnDef<any>[]>(() => {
    if (!queryData?.csvFile?.columnHeaders) return []

    console.log("Creating columns for headers:", queryData.csvFile.columnHeaders)

    const dataColumns: ColumnDef<any>[] = queryData.csvFile.columnHeaders.map((header: string) => ({
      accessorKey: header,
      header: ({ column }) => <DraggableColumnHeader header={{ column, id: header }} table={table} />,
      cell: EditableCell,
      size: 150,
      minSize: 80,
      maxSize: 300,
    }))

    // Add selection column at the beginning
    return [
      {
        id: "select",
        header: ({ table }) => (
          <div className="flex items-center justify-center w-full">
            <Checkbox
              checked={table.getIsAllPageRowsSelected()}
              onCheckedChange={(value) => table.toggleAllPageRowsSelected(!!value)}
              aria-label="Select all"
              className="h-3 w-3 sm:h-4 sm:w-4"
            />
          </div>
        ),
        cell: ({ row }) => (
          <div className="flex items-center justify-center w-full">
            <Checkbox
              checked={row.getIsSelected()}
              onCheckedChange={(value) => row.toggleSelected(!!value)}
              aria-label="Select row"
              className="h-3 w-3 sm:h-4 sm:w-4"
            />
          </div>
        ),
        enableSorting: false,
        enableHiding: false,
        size: 50,
        minSize: 50,
        maxSize: 50,
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
      columnOrder,
    },
    onColumnOrderChange: setColumnOrder,
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

  const insights = queryData?.insights
  const columnHeaders = queryData?.csvFile?.columnHeaders || []

  // Helper to get badge color and label
  const typeBadge = (type: string) => {
    let color = 'bg-gray-200 text-gray-700'
    let label = 'Text'
    if (type === 'number') { color = 'bg-blue-100 text-blue-800'; label = '123' }
    else if (type === 'date') { color = 'bg-yellow-100 text-yellow-800'; label = '📅' }
    else if (type === 'email') { color = 'bg-green-100 text-green-800'; label = '@' }
    else if (type === 'website') { color = 'bg-purple-100 text-purple-800'; label = '🌐' }
    return <span className={`ml-2 px-2 py-0.5 rounded text-xs font-semibold ${color}`}>{label}</span>
  }

  // Helper to check if a value matches the detected type
  const matchesType = (value: string, type: string) => {
    if (type === 'number') return /^-?\d+(\.\d+)?$/.test(value)
    if (type === 'date') return !isNaN(Date.parse(value))
    if (type === 'email') return /^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(value)
    if (type === 'website') return /^(https?:\/\/)?([\w-]+\.)+[\w-]+(\/\S*)?$/.test(value)
    return true
  }

  if (error) return <div className="text-red-500 p-4">Error: {error.message}</div>
  if (!queryData?.rows || queryData.rows.length === 0) {
    return <div className="p-4 text-gray-500">No data found in this CSV file.</div>
  }

  const handleDragEnd = (event: DragEndEvent) => {
    const { active, over } = event

    if (active && over && active.id !== over.id) {
      setColumnOrder((prevOrder) => {
        const oldIndex = prevOrder.indexOf(active.id.toString())
        const newIndex = prevOrder.indexOf(over.id.toString())
        return arrayMove(prevOrder, oldIndex, newIndex)
      })
    }
  }

  return (
    <div className="w-full space-y-4 p-2 sm:p-4">
      {/* Loading state */}
      {isLoading && (
        <div className="flex items-center justify-center p-8">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
          <span className="ml-2">Loading CSV data...</span>
        </div>
      )}

      {/* Debug info - remove in production */}
      <div className="text-xs text-gray-500 p-2 bg-gray-50 rounded">
        Debug: {data.length} rows loaded, {columns.length - 1} data columns
      </div>

      {/* Toolbar */}
      <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
        <div className="flex flex-col sm:flex-row items-start sm:items-center space-y-2 sm:space-y-0 sm:space-x-2 w-full sm:w-auto">
          <Input
            placeholder="Filter all columns..."
            value={globalFilter ?? ""}
            onChange={(e) => setGlobalFilter(e.target.value)}
            className="w-full sm:max-w-sm"
          />

          {/* Column visibility dropdown */}
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button variant="outline" className="w-full sm:w-auto">
                <Settings2 className="mr-2 h-4 w-4" />
                <span className="hidden sm:inline">Columns</span>
                <span className="sm:hidden">Show/Hide</span>
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end" className="w-56">
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
                      <span className="truncate">{column.id}</span>
                    </DropdownMenuCheckboxItem>
                  )
                })}
            </DropdownMenuContent>
          </DropdownMenu>
        </div>

        {/* Selection actions */}
        {selectedRowCount > 0 && (
          <div className="flex items-center space-x-2 w-full sm:w-auto">
            <span className="text-sm text-muted-foreground">{selectedRowCount} row(s) selected</span>
            <Button variant="outline" size="sm" className="hidden sm:flex">
              <Trash2 className="mr-2 h-4 w-4" />
              Delete Selected
            </Button>
            <Button variant="outline" size="sm" className="sm:hidden">
              <Trash2 className="h-4 w-4" />
            </Button>
          </div>
        )}
      </div>

      {/* Table Container with horizontal scroll */}
      <div className="w-full overflow-hidden shadow-md">
        <div className="overflow-x-auto">
          <div className="rounded-md  min-w-full">
            <DndContext sensors={sensors} collisionDetection={closestCenter} onDragEnd={handleDragEnd}>
              <table className="w-full table-fixed">
                <thead>
                  {table.getHeaderGroups().map((headerGroup) => (
                    <SortableContext
                      key={headerGroup.id}
                      items={headerGroup.headers.map((h) => h.id)}
                      strategy={horizontalListSortingStrategy}
                    >
                      <tr className="border-b bg-muted/50">
                        {headerGroup.headers.map((header) => {
                          const colType = insights?.columns?.[header.column.id]?.type
                          return (
                            <th
                              key={header.id}
                              className="px-2 sm:px-4 py-3 text-left font-medium text-xs sm:text-sm"
                              style={{
                                width: header.column.id === "select" ? "50px" : `${Math.max(header.getSize(), 120)}px`,
                                minWidth: header.column.id === "select" ? "50px" : "80px",
                              }}
                            >
                              <div className="truncate">
                                {header.isPlaceholder
                                  ? null
                                  : flexRender(header.column.columnDef.header, header.getContext())}
                                {colType && typeBadge(colType)}
                              </div>
                            </th>
                          )
                        })}
                      </tr>
                    </SortableContext>
                  ))}
                </thead>
                <tbody>
                  {table.getRowModel().rows?.length ? (
                    table.getRowModel().rows.map((row) => (
                      <tr
                        key={row.id}
                        className={`border-b hover:bg-muted/50 ${row.getIsSelected() ? "bg-muted" : ""}`}
                        tabIndex={-1}
                      >
                        {row.getVisibleCells().map((cell) => {
                          const colType = insights?.columns?.[cell.column.id]?.type
                          const value = cell.getValue() ?? ''
                          const isMismatch = colType && value && !matchesType(String(value), colType)
                          return (
                            <td
                              key={cell.id}
                              className={`px-2 sm:px-4 py-2 text-xs sm:text-sm focus-within:bg-muted/30${isMismatch ? ' bg-red-100 text-red-700' : ''}`}
                              style={{
                                width: cell.column.id === "select" ? "50px" : `${Math.max(cell.column.getSize(), 120)}px`,
                                minWidth: cell.column.id === "select" ? "50px" : "80px",
                              }}
                              title={isMismatch ? `Value does not match detected type: ${colType}` : ''}
                            >
                              <div className="truncate">{flexRender(cell.column.columnDef.cell, cell.getContext())}</div>
                            </td>
                          )
                        })}
                      </tr>
                    ))
                  ) : (
                    <tr>
                      <td colSpan={columns.length} className="h-24 text-center text-sm">
                        No results found.
                      </td>
                    </tr>
                  )}
                </tbody>
              </table>
            </DndContext>
          </div>
        </div>
      </div>

      {/* Keyboard shortcuts help */}
      <div className="text-xs text-muted-foreground border rounded-md p-3 bg-muted/10 hidden md:block">
        <p className="font-medium mb-1">Keyboard shortcuts:</p>
        <div className="grid grid-cols-2 gap-2">
          <div>
            <span className="font-mono bg-muted px-1 rounded">Enter</span> - Edit cell / Save changes
          </div>
          <div>
            <span className="font-mono bg-muted px-1 rounded">Escape</span> - Cancel editing
          </div>
          <div>
            <span className="font-mono bg-muted px-1 rounded">Tab</span> - Navigate between cells
          </div>
          <div>
            <span className="font-mono bg-muted px-1 rounded">Arrow keys</span> - Navigate between cells
          </div>
        </div>
      </div>

      {/* Pagination */}
      <div className="flex flex-col sm:flex-row items-center justify-between space-y-2 sm:space-y-0 sm:space-x-2 py-4">
        <div className="text-xs sm:text-sm text-muted-foreground text-center sm:text-left">
          Showing {(page - 1) * 20 + 1} to {Math.min(page * 20, queryData?.pagination?.total || 0)} of{" "}
          {queryData?.pagination?.total || 0} entries
        </div>
        <div className="flex items-center space-x-2">
          <Button
            variant="outline"
            size="sm"
            onClick={() => setPage(page - 1)}
            disabled={page === 1}
            className="text-xs sm:text-sm"
            aria-label="Previous page"
          >
            <span className="hidden sm:inline">Previous</span>
            <span className="sm:hidden">Prev</span>
          </Button>
          <div className="flex items-center space-x-1 text-xs sm:text-sm">
            <span>Page</span>
            <input
              type="number"
              min={1}
              max={queryData?.pagination?.totalPages || 1}
              value={page}
              onChange={(e) => {
                const value = Number.parseInt(e.target.value)
                if (value > 0 && value <= (queryData?.pagination?.totalPages || 1)) {
                  setPage(value)
                }
              }}
              className="w-12 text-center border rounded p-1"
              aria-label="Page number"
            />
            <span>of</span>
            <span className="font-medium">{queryData?.pagination?.totalPages || 1}</span>
          </div>
          <Button
            variant="outline"
            size="sm"
            onClick={() => setPage(page + 1)}
            disabled={page === queryData?.pagination?.totalPages}
            className="text-xs sm:text-sm"
            aria-label="Next page"
          >
            Next
          </Button>
        </div>
      </div>
    </div>
  )
}

export default CsvDataTable
