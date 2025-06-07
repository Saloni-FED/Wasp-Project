import React, { useRef, useState } from 'react'

const ImportBatchStep1: React.FC = () => {
  const [batchName, setBatchName] = useState('nick')
  const [batchType, setBatchType] = useState<'Company' | 'People'>('People')
  const [file, setFile] = useState<File | null>(null)
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
          <svg className="w-8 h-8 mb-2 text-gray-400" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" d="M12 4v16m8-8H4" />
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
            <span className="ml-2 text-gray-400 text-sm">
              {file ? file.name : 'No file chosen'}
            </span>
          </div>
        </div>
      </div>

      {/* Buttons */}
      <div className="flex justify-between mt-6">
        <button
          className="text-gray-500 hover:underline"
          type="button"
        >
          Back
        </button>
        <button
          className="bg-gray-200 text-gray-500 px-6 py-2 rounded cursor-not-allowed"
          type="button"
          disabled={!file}
        >
          Continue
        </button>
      </div>
    </div>
  )
}

export default ImportBatchStep1 