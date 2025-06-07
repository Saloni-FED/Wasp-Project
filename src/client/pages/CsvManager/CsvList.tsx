import React, { useState } from 'react'
import { useQuery, getUserCsvFiles, useAction, deleteCsvFile } from 'wasp/client/operations'
import CsvDataTable from './CsvDataTable'
import { Trash2 } from 'lucide-react'
import {
  Dialog,
  DialogTrigger,
  DialogContent,
  DialogHeader,
  DialogFooter,
  DialogTitle,
  DialogDescription,
} from '../../../components/ui/dialog'

interface CsvListProps {
  onBackToImportStep1?: () => void
}

const CsvList: React.FC<CsvListProps> = ({ onBackToImportStep1 }) => {
    const { data: files, isLoading, error, refetch } = useQuery(getUserCsvFiles)
    const [selectedFileId, setSelectedFileId] = useState<string | null>(null)
    const deleteFile = useAction(deleteCsvFile)
    const [deletingId, setDeletingId] = useState<string | null>(null)
    const [dialogOpenId, setDialogOpenId] = useState<string | null>(null)

    const handleDelete = async (fileId: string) => {
        setDeletingId(fileId)
        try {
            await deleteFile({ fileId })
            await refetch()
            if (selectedFileId === fileId) setSelectedFileId(null)
        } catch (e) {
            alert('Failed to delete file.')
        } finally {
            setDeletingId(null)
            setDialogOpenId(null)
        }
    }

    if (isLoading) return <div>Loading files...</div>
    if (error) return <div className="text-red-500">{error.message}</div>

    return (
        <div className="px-2 py-4 max-w-5xl mx-auto">
            <div className="flex justify-between items-center mb-4">
                <h2 className="text-xl font-bold">Uploaded CSV Files</h2>
                {onBackToImportStep1 && (
                  <button
                    className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700 transition"
                    onClick={onBackToImportStep1}
                  >
                    + Import New CSV
                  </button>
                )}
            </div>
            <div className="overflow-x-auto rounded shadow border bg-white">
                <table className="min-w-[600px] w-full text-sm sm:text-base">
                    <thead>
                        <tr>
                            <th className="px-2 sm:px-4 py-2 border">File Name</th>
                            <th className="px-2 sm:px-4 py-2 border">Uploaded At</th>
                            <th className="px-2 sm:px-4 py-2 border">Row Count</th>
                            <th className="px-2 sm:px-4 py-2 border">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        {files?.map(file => (
                            <tr key={file.id} className={selectedFileId === file.id ? 'bg-gray-100' : ''}>
                                <td className="px-2 sm:px-4 py-2 border break-all">{file.originalName}</td>
                                <td className="px-2 sm:px-4 py-2 border">{new Date(file.uploadedAt).toLocaleString()}</td>
                                <td className="px-2 sm:px-4 py-2 border">{file.rowCount}</td>
                                <td className="px-2 sm:px-4 py-2 border flex gap-2 items-center">
                                    <button
                                        onClick={() => setSelectedFileId(file.id)}
                                        className="underline text-blue-600"
                                    >
                                        View Data
                                    </button>
                                    <Dialog open={dialogOpenId === file.id} onOpenChange={open => setDialogOpenId(open ? file.id : null)}>
                                        <DialogTrigger asChild>
                                            <button
                                                className="text-red-600 hover:bg-red-50 rounded p-1"
                                                disabled={deletingId === file.id}
                                                title="Delete file"
                                                onClick={e => { e.stopPropagation(); setDialogOpenId(file.id) }}
                                            >
                                                <Trash2 className="inline w-4 h-4" />
                                            </button>
                                        </DialogTrigger>
                                        <DialogContent>
                                            <DialogHeader>
                                                <DialogTitle>Delete CSV File</DialogTitle>
                                                <DialogDescription>
                                                    Are you sure you want to delete <span className="font-semibold">{file.originalName}</span>? This action cannot be undone.
                                                </DialogDescription>
                                            </DialogHeader>
                                            <DialogFooter>
                                                <button
                                                    className="px-4 py-2 rounded bg-gray-200 hover:bg-gray-300"
                                                    onClick={() => setDialogOpenId(null)}
                                                    disabled={deletingId === file.id}
                                                >
                                                    Cancel
                                                </button>
                                                <button
                                                    className="px-4 py-2 rounded bg-red-600 text-white hover:bg-red-700"
                                                    onClick={() => handleDelete(file.id)}
                                                    disabled={deletingId === file.id}
                                                >
                                                    {deletingId === file.id ? 'Deleting...' : 'Delete'}
                                                </button>
                                            </DialogFooter>
                                        </DialogContent>
                                    </Dialog>
                                </td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            </div>
            {selectedFileId && (
                <div className="mt-6">
                    <CsvDataTable fileId={selectedFileId} />
                </div>
            )}
        </div>
    )
}

export default CsvList