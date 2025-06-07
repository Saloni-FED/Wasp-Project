-- AlterTable
ALTER TABLE "CsvFile" ADD COLUMN     "batchName" TEXT NOT NULL DEFAULT 'default-batch',
ADD COLUMN     "batchType" TEXT NOT NULL DEFAULT 'standard',
ADD COLUMN     "fieldMapping" JSONB NOT NULL DEFAULT '{}';
