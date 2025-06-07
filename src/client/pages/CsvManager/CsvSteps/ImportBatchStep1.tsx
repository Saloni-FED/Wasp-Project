import React, { useRef, useState } from 'react'

interface ImportBatchStep1Props {
  initialBatchName?: string
  initialBatchType?: 'Company' | 'People'
  initialFile?: File | null
  onContinue: (data: { batchName: string, batchType: 'Company' | 'People', file: File }) => void
}

const ImportBatchStep1: React.FC<ImportBatchStep1Props> = ({
  initialBatchName = '',
  initialBatchType = 'Company',
  initialFile = null,
  onContinue
}) => {
  const [batchName, setBatchName] = useState(initialBatchName)
  const [batchType, setBatchType] = useState<'Company' | 'People'>(initialBatchType)
  const [file, setFile] = useState<File | null>(initialFile)
  const fileInputRef = useRef<HTMLInputElement>(null)
  const [dragActive, setDragActive] = useState(false)

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files[0]) {
      setFile(e.target.files[0])
    }
  }

  const handleDrop = (e: React.DragEvent<HTMLDivElement>) => {
    e.preventDefault()
    e.stopPropagation()
    setDragActive(false)
    if (e.dataTransfer.files && e.dataTransfer.files[0]) {
      setFile(e.dataTransfer.files[0])
    }
  }

  const handleDrag = (e: React.DragEvent<HTMLDivElement>) => {
    e.preventDefault()
    e.stopPropagation()
    if (e.type === 'dragenter' || e.type === 'dragover') {
      setDragActive(true)
    } else if (e.type === 'dragleave') {
      setDragActive(false)
    }
  }

  const removeFile = () => {
    setFile(null)
    if (fileInputRef.current) {
      fileInputRef.current.value = ''
    }
  }

  const formatFileSize = (bytes: number) => {
    if (bytes < 1024) return `${bytes} B`
    if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(0)} KB`
    return `${(bytes / (1024 * 1024)).toFixed(1)} MB`
  }

  const canContinue = !!batchName && !!file

  return (
    <div className="max-w-xl mx-auto bg-white rounded-lg shadow-lg p-8 mt-10">
      {/* Step Indicator */}
      <div className="flex items-center mb-8">
        {[1, 2, 3, 4].map((step, idx) => (
          <React.Fragment key={step}>
            <div className="flex flex-col items-center">
              <div
                className={`w-8 h-8 flex items-center justify-center rounded-full font-bold text-lg
                  ${step === 1 ? 'bg-black text-white' : 'bg-gray-200 text-gray-500'}
                `}
              >
                {step}
              </div>
              <span className={`text-xs mt-2 ${step === 1 ? 'text-black' : 'text-gray-400'}`}>{
                ['Upload File', 'Map Fields', 'Review', 'Complete'][idx]
              }</span>
            </div>
            {idx < 3 && <div className="flex-1 h-1 bg-gray-200 mx-2 mt-4" />}
          </React.Fragment>
        ))}
      </div>

      {/* Batch Name */}
      <div className="mb-4">
        <label className="block text-gray-700 font-medium mb-1">Batch Name</label>
        <input
          type="text"
          className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-black"
          value={batchName}
          onChange={e => setBatchName(e.target.value)}
          placeholder="Enter batch name"
        />
      </div>

      {/* Batch Type */}
      <div className="mb-4">
        <label className="block text-gray-700 font-medium mb-1">Batch Type</label>
        <div className="flex items-center space-x-6">
          <label className="flex items-center space-x-2">
            <input
              type="radio"
              name="batchType"
              value="Company"
              checked={batchType === 'Company'}
              onChange={() => setBatchType('Company')}
              className="form-radio text-black"
            />
            <span>Company</span>
          </label>
          <label className="flex items-center space-x-2">
            <input
              type="radio"
              name="batchType"
              value="People"
              checked={batchType === 'People'}
              onChange={() => setBatchType('People')}
              className="form-radio text-black"
            />
            <span>People</span>
          </label>
        </div>
      </div>

      {/* File Upload */}
      <div className="mb-6">
        <label className="block text-gray-700 font-medium mb-1">Upload CSV File</label>
        {file ? (
          <div className="border border-gray-200 rounded-lg p-4">
            <div className="flex items-center justify-between">
              <div className="flex items-center">
                <svg 
                  className="w-6 h-6 text-gray-500 mr-3" 
                  fill="none" 
                  stroke="currentColor" 
                  viewBox="0 0 24 24"
                >
                  <path 
                    strokeLinecap="round" 
                    strokeLinejoin="round" 
                    strokeWidth={2} 
                    d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" 
                  />
                </svg>
                <div>
                  <p className="font-medium text-gray-900">{file.name}</p>
                  <p className="text-sm text-gray-500">{formatFileSize(file.size)}</p>
                </div>
              </div>
              <button
                onClick={removeFile}
                className="text-gray-400 hover:text-gray-600"
              >
                <svg 
                  className="w-5 h-5" 
                  fill="none" 
                  stroke="currentColor" 
                  viewBox="0 0 24 24"
                >
                  <path 
                    strokeLinecap="round" 
                    strokeLinejoin="round" 
                    strokeWidth={2} 
                    d="M6 18L18 6M6 6l12 12" 
                  />
                </svg>
              </button>
            </div>
          </div>
        ) : (
          <div
            className={`border-2 border-dashed rounded-lg p-8 text-center cursor-pointer transition-colors flex flex-col items-center justify-center ${
              dragActive ? 'border-blue-500 bg-blue-50' : 'border-gray-300'
            }`}
            onClick={() => fileInputRef.current?.click()}
            onDragEnter={handleDrag}
            onDragOver={handleDrag}
            onDragLeave={handleDrag}
            onDrop={handleDrop}
          >
            <input
              type="file"
              accept=".csv"
              ref={fileInputRef}
              className="hidden"
              onChange={handleFileChange}
            />
            <svg 
              className="w-8 h-8 mb-2 text-gray-400" 
              fill="none" 
              stroke="currentColor" 
              viewBox="0 0 24 24"
            >
              <path 
                strokeLinecap="round" 
                strokeLinejoin="round" 
                strokeWidth={2} 
                d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12" 
              />
            </svg>
            <span className="text-gray-500">
              Drag and drop your CSV file here, or click to browse
            </span>
            <div className="mt-2">
              <label className="inline-block bg-gray-100 px-3 py-1 rounded cursor-pointer text-sm font-medium text-gray-700">
                <span className="font-semibold">Choose file</span>
                <input
                  type="file"
                  accept=".csv"
                  ref={fileInputRef}
                  className="hidden"
                  onChange={handleFileChange}
                />
              </label>
              <span className="ml-2 text-gray-400 text-sm">No file chosen</span>
            </div>
          </div>
        )}
      </div>

      {/* Buttons */}
      <div className="flex justify-between mt-6">
        <button
          className="text-gray-500 hover:underline"
          type="button"
          // No back button for step 1
          disabled
        >
          Back
        </button>
        <button
          className={`px-6 py-2 rounded ${
            canContinue 
              ? 'bg-black text-white hover:bg-gray-800' 
              : 'bg-gray-200 text-gray-500 cursor-not-allowed'
          }`}
          type="button"
          disabled={!canContinue}
          onClick={() => file && onContinue({ batchName, batchType, file })}
        >
          Continue
        </button>
      </div>
    </div>
  )
}

export default ImportBatchStep1