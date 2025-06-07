import React from 'react'

interface ImportBatchStep3Props {
  batchName: string
  batchType: string
  file: File | null
  mapping: Record<string, string>
  previewRows: Array<Record<string, string>>
  recordCount: number
  onBack: () => void
  onContinue: () => void
}

const ImportBatchStep3: React.FC<ImportBatchStep3Props> = ({
  batchName,
  batchType,
  file,
  mapping,
  previewRows,
  recordCount,
  onBack,
  onContinue
}) => {
  // Get mapped CSV columns for preview table header
  const mappedCsvColumns = Object.values(mapping).filter(v => v && v !== '-- Not Mapped --')

  return (
    <div className="max-w-xl mx-auto bg-white rounded-lg shadow-lg p-8 mt-10">
      {/* Step Indicator */}
      <div className="flex items-center mb-8">
        {[1, 2, 3, 4].map((step, idx) => (
          <React.Fragment key={step}>
            <div className="flex flex-col items-center">
              <div
                className={`w-8 h-8 flex items-center justify-center rounded-full font-bold text-lg
                  ${step === 3 ? 'bg-black text-white' : 'bg-gray-200 text-gray-500'}
                `}
              >
                {step}
              </div>
              <span className={`text-xs mt-2 ${step === 3 ? 'text-black' : 'text-gray-400'}`}>{
                ['Upload File', 'Map Fields', 'Review', 'Complete'][idx]
              }</span>
            </div>
            {idx < 3 && <div className="flex-1 h-1 bg-gray-200 mx-2 mt-4" />}
          </React.Fragment>
        ))}
      </div>
      <h2 className="text-xl font-bold mb-4">Batch Information</h2>
      <div className="bg-gray-50 rounded p-4 flex flex-wrap mb-6">
        <div className="w-1/2 mb-2"><span className="font-semibold">Batch Name</span><div>{batchName}</div></div>
        <div className="w-1/2 mb-2"><span className="font-semibold">Batch Type</span><div>{batchType}</div></div>
        <div className="w-1/2 mb-2"><span className="font-semibold">File</span><div>{file ? file.name : 'No file selected'}</div></div>
        <div className="w-1/2 mb-2"><span className="font-semibold">Records</span><div>{recordCount} (preview)</div></div>
      </div>
      <h2 className="text-xl font-bold mb-2">Field Mappings</h2>
      <div className="bg-gray-50 rounded p-4 mb-6">
        <table className="min-w-full">
          <thead>
            <tr>
              <th className="text-left text-xs font-semibold text-gray-600 pb-1">SYSTEM FIELD</th>
              <th className="text-left text-xs font-semibold text-gray-600 pb-1">CSV COLUMN</th>
            </tr>
          </thead>
          <tbody>
            {Object.entries(mapping).map(([sys, csv]) => (
              csv && csv !== '-- Not Mapped --' && (
                <tr key={sys}>
                  <td className="py-1 text-sm font-medium text-gray-700">{sys}</td>
                  <td className="py-1 text-sm">{csv}</td>
                </tr>
              )
            ))}
          </tbody>
        </table>
      </div>
      <h2 className="text-xl font-bold mb-2">Data Preview</h2>
      <div className="bg-gray-50 rounded p-4 mb-6 overflow-x-auto">
        <table className="min-w-full text-xs">
          <thead>
            <tr>
              {mappedCsvColumns.map(col => (
                <th key={col} className="px-2 py-1 text-left font-semibold text-gray-600 uppercase">{col}</th>
              ))}
            </tr>
          </thead>
          <tbody>
            {previewRows.map((row, i) => (
              <tr key={i} className="border-t border-gray-100">
                {mappedCsvColumns.map(col => (
                  <td key={col} className="px-2 py-1 whitespace-nowrap">{row[col]}</td>
                ))}
              </tr>
            ))}
          </tbody>
        </table>
      </div>
      <div className="flex justify-between mt-6">
        <button className="text-gray-500 hover:underline" type="button" onClick={onBack}>Back</button>
        <button className="px-6 py-2 rounded bg-black text-white hover:bg-gray-800" type="button" onClick={onContinue}>Import Batch</button>
      </div>
    </div>
  )
}

export default ImportBatchStep3 