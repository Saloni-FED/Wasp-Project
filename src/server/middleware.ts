import express from "express"
import type { MiddlewareConfigFn } from "wasp/server"

export const serverMiddlewareFn: MiddlewareConfigFn = (middlewareConfig) => {
  // Increase the JSON body parser limit for large CSV uploads
  middlewareConfig.set(
    "express.json",
    express.json({
      limit: "50mb", // Adjust based on your needs
    }),
  )

  // Also increase URL encoded limit if needed
  middlewareConfig.set(
    "express.urlencoded",
    express.urlencoded({
      extended: false,
      limit: "50mb",
    }),
  )

  return middlewareConfig
}
