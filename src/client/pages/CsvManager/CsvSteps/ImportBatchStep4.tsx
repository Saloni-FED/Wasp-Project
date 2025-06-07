import React from 'react'

const ImportBatchStep4: React.FC<{ onDone: () => void }> = ({ onDone }) => {
  return (
    <div className="max-w-xl mx-auto bg-white rounded-lg shadow-lg p-8 mt-10 text-center">
      {/* Step Indicator */}
      <div className="flex items-center mb-8">
        {[1, 2, 3, 4].map((step, idx) => (
          <React.Fragment key={step}>
            <div className="flex flex-col items-center">
              <div
                className={`w-8 h-8 flex items-center justify-center rounded-full font-bold text-lg
                  ${step === 4 ? 'bg-black text-white' : 'bg-gray-200 text-gray-500'}
                `}
              >
                {step}
              </div>
              <span className={`text-xs mt-2 ${step === 4 ? 'text-black' : 'text-gray-400'}`}>{
                ['Upload File', 'Map Fields', 'Review', 'Complete'][idx]
              }</span>
            </div>
            {idx < 3 && <div className="flex-1 h-1 bg-gray-200 mx-2 mt-4" />}
          </React.Fragment>
        ))}
      </div>
      <div className="mb-6">
        <h3 className="text-2xl font-bold mb-2">Import Complete!</h3>
        <p className="text-gray-700">Your CSV batch has been successfully imported.</p>
      </div>
      <button
        className="px-6 py-2 rounded bg-black text-white hover:bg-gray-800 mt-4"
        type="button"
        onClick={onDone}
      >
        Done
      </button>
    </div>
  )
}

export default ImportBatchStep4 