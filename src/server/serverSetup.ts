import express from 'express'

export const serverSetup = (app) => {
  // Increase the body size limit for JSON and URL-encoded data
  app.use(express.json({ limit: '50mb' }))
  app.use(express.urlencoded({ limit: '50mb', extended: true }))
  
  console.log('Server setup completed - increased body size limits')
}