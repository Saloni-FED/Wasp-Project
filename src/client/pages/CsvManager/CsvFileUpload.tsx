import React, { useState } from 'react';
import Papa from 'papaparse';
import type { ParseResult } from 'papaparse';

import ImportBatchStep1 from './CsvSteps/ImportBatchStep1';
import ImportBatchStep2 from './CsvSteps/ImportBatchStep2';
import ImportBatchStep3 from './CsvSteps/ImportBatchStep3';
import ImportBatchStep4 from './CsvSteps/ImportBatchStep4';
import { uploadCsv } from 'wasp/client/operations';
import  CsvList from './CsvList'

interface CsvFile {
  id: string;
  originalName: string;
  uploadedAt: string;
  rowCount: number;
}

const CsvFileUpload: React.FC = () => {
  // Stepper state
  const [step, setStep] = useState(1);
  // Data collected through steps
  const [batchName, setBatchName] = useState('');
  const [batchType, setBatchType] = useState<'Company' | 'People'>('Company');
  const [file, setFile] = useState<File | null>(null);
  const [mapping, setMapping] = useState<Record<string, string>>({});
  const [parsedRows, setParsedRows] = useState<Array<Record<string, string>>> ([]);
  const [csvHeaders, setCsvHeaders] = useState<string[]> ([]);
  const [parseError, setParseError] = useState<string | null>(null);
  const [showFileList, setShowFileList] = useState(false);
  // Step 1: Upload File and batch info
  const handleStep1Continue = (data: { batchName: string, batchType: 'Company' | 'People', file: File }) => {
    setBatchName(data.batchName);
    setBatchType(data.batchType);
    setFile(data.file);
    setParseError(null);
    // Check for empty file
    if (data.file.size === 0) {
      setParseError('The selected file is empty. Please upload a valid CSV file.');
      setParsedRows([]);
      setCsvHeaders([]);
      return;
    }
    // Parse CSV file
    Papa.parse(data.file, {
      header: true,
      skipEmptyLines: true,
      delimiter: ',', // Force comma delimiter
      complete: (results : any) => {
        if (results.errors && results.errors.length > 0) {
          setParseError('Failed to parse CSV: ' + results.errors[0].message);
          setParsedRows([]);
          setCsvHeaders([]);
        } else {
          const rows = results.data as Array<Record<string, string>>;
          const headers = results.meta.fields || [];
          console.debug('Parsed CSV headers:', headers);
          setParsedRows(rows);
          setCsvHeaders(headers);
          setStep(2);
        }
      },
      error: (err: Error) => {
        setParseError('Failed to parse CSV: ' + err.message);
        setParsedRows([]);
        setCsvHeaders([]);
      }
    });
  };

  // Step 2: Map Fields
  const handleStep2Continue = (mapping: Record<string, string>) => {
    setMapping(mapping);
    setStep(3);
  };

  // Step 3: Review
  const handleStep3Continue = async () => {
    if (!file) {
      setParseError('No file selected.');
      return;
    }
    try {
      const fileContent = await file.text();
      await uploadCsv({
        batchName,
        batchType,
        mapping,
        fileName: file.name,
        originalName: file.name,
        fileContent,
      });
      setStep(4);
    } catch (error) {
      setParseError('Failed to upload CSV: ' + (error as Error).message);
    }
  };

  // Step 4: Complete
  const handleDone = () => {
    // Reset all state for a new import
    setBatchName('');
    setBatchType('Company');
    setFile(null);
    setMapping({});
    setParsedRows([]);
    setCsvHeaders([]);
    setParseError(null);
    setShowFileList(true);
  };
  if (showFileList) {
    return <CsvList onBackToImportStep1={() => { setShowFileList(false); setStep(1); }} />;
  }
  // Step 1 props: pass handlers to collect data
  if (step === 1) {
    return (
      <>
        <ImportBatchStep1
          initialBatchName={batchName}
          initialBatchType={batchType}
          initialFile={file}
          onContinue={handleStep1Continue}
          onViewCsvList={() => setShowFileList(true)}
        />
        {parseError && <div className="text-red-500 text-center mt-4">{parseError}</div>}
      </>
    );
  }

  // Step 2 props: pass file columns, mapping, and navigation
  if (step === 2) {
    console.debug('Passing csvHeaders to ImportBatchStep2:', csvHeaders);
    return (
      <ImportBatchStep2
        csvColumns={csvHeaders}
        onBack={() => setStep(1)}
        onContinue={handleStep2Continue}
      />
    );
  }

  // Step 3: Review
  if (step === 3) {
    const previewRows = parsedRows.slice(0, 3);
    const recordCount = parsedRows.length;
    return (
      <ImportBatchStep3
        batchName={batchName}
        batchType={batchType}
        file={file}
        mapping={mapping}
        previewRows={previewRows}
        recordCount={recordCount}
        onBack={() => setStep(2)}
        onContinue={handleStep3Continue}
      />
    );
  }

  // Step 4: Complete
  return <ImportBatchStep4 onDone={handleDone} />;
};

export default CsvFileUpload;