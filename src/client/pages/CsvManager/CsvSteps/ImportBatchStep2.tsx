import React, { useState } from 'react'

// Example props: systemFields, csvColumns, onBack, onContinue
const systemFields = [
  { name: 'Company Name', required: true },
  { name: 'Industry', required: false },
  { name: 'Website', required: false },
  { name: 'Employee Count', required: false },
  { name: 'Annual Revenue', required: false },
]

const ImportBatchStep2: React.FC<{
  csvColumns?: string[]
  onBack?: () => void
  onContinue?: (mapping: Record<string, string>) => void
}> = ({ csvColumns = ['Company', 'Website', 'Industry', 'Size', 'Revenue', 'Country', 'State', 'City', 'Founded'], onBack, onContinue }) => {
  const [mapping, setMapping] = useState<Record<string, string>>({})

  const handleSelect = (field: string, value: string) => {
    setMapping(prev => ({ ...prev, [field]: value }))
  }

  // Required fields must be mapped (not "-- Not Mapped --")
  const allRequiredMapped = systemFields.every(f => !f.required || (mapping[f.name] && mapping[f.name] !== '-- Not Mapped --')) && (mapping['Company Name'] && mapping['Company Name'] !== '-- Not Mapped --')

  return (
    <div className="max-w-xl mx-auto bg-white rounded-lg shadow-lg p-8 mt-10">
      {/* Step Indicator */}
      <div className="flex items-center mb-8">
        {[1, 2, 3, 4].map((step, idx) => (
          <React.Fragment key={step}>
            <div className="flex flex-col items-center">
              <div
                className={`w-8 h-8 flex items-center justify-center rounded-full font-bold text-lg
                  ${step === 2 ? 'bg-black text-white' : 'bg-gray-200 text-gray-500'}
                `}
              >
                {step}
              </div>
              <span className={`text-xs mt-2 ${step === 2 ? 'text-black' : 'text-gray-400'}`}>{
                ['Upload File', 'Map Fields', 'Review', 'Complete'][idx]
              }</span>
            </div>
            {idx < 3 && <div className="flex-1 h-1 bg-gray-200 mx-2 mt-4" />}
          </React.Fragment>
        ))}
      </div>

      <div className="mb-4 text-gray-700">
        Map your CSV columns to our system fields. Required fields are marked with an asterisk (*).
      </div>

      {/* Mapping Table */}
      <div className="overflow-x-auto mb-6">
        <table className="min-w-full border border-gray-200 rounded">
          <thead>
            <tr className="bg-gray-50">
              <th className="px-4 py-2 text-left text-xs font-semibold text-gray-600">SYSTEM FIELD</th>
              <th className="px-4 py-2 text-left text-xs font-semibold text-gray-600">CSV COLUMN</th>
            </tr>
          </thead>
          <tbody>
            {systemFields.map(field => (
              <tr key={field.name} className="border-t border-gray-100">
                <td className="px-4 py-2 text-sm font-medium text-gray-700">
                  {field.name} {field.required && <span className="text-red-500">*</span>}
                </td>
                <td className="px-4 py-2">
                  <select
                    className={`w-full border rounded px-2 py-1 text-sm focus:outline-none focus:ring-2 focus:ring-black ${field.required && (!mapping[field.name] || mapping[field.name] === '-- Not Mapped --') ? 'border-red-300' : 'border-gray-300'}`}
                    value={mapping[field.name] || '-- Not Mapped --'}
                    onChange={e => handleSelect(field.name, e.target.value)}
                  >
                    <option>-- Not Mapped --</option>
                    {csvColumns.map(col => (
                      <option key={col} value={col}>{col}</option>
                    ))}
                  </select>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {/* Buttons */}
      <div className="flex justify-between mt-6">
        <button
          className="text-gray-500 hover:underline"
          type="button"
          onClick={onBack}
        >
          Back
        </button>
        <button
          className={`px-6 py-2 rounded ${allRequiredMapped ? 'bg-black text-white hover:bg-gray-800' : 'bg-gray-200 text-gray-500 cursor-not-allowed'}`}
          type="button"
          disabled={!allRequiredMapped}
          onClick={() => allRequiredMapped && onContinue && onContinue(mapping)}
        >
          Continue
        </button>
      </div>
    </div>
  )
}

export default ImportBatchStep2
