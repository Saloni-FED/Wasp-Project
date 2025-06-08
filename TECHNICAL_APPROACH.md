# Technical Approach

## Key Architectural Decisions

- **Full-stack with Wasp:**  
  The project is built using the Wasp framework, which provides a full-stack environment integrating React (frontend), Node.js (backend), and Prisma (ORM/database). This choice enables rapid development, type safety, and a clear separation of concerns.

- **Stepper-based Import Flow:**  
  The CSV import process is divided into four clear steps (Upload, Map Fields, Review, Complete), each implemented as a separate React component. This modular approach improves user experience and code maintainability.

- **Componentization:**  
  The UI is split into reusable components such as `CsvList`, `CsvDataTable`, and each import step. This makes the codebase easier to extend and maintain.

- **Server Actions and Queries:**  
  All data mutations (upload, delete, edit) are handled via Wasp actions, ensuring security, backend validation, and proper user authorization.

---

## Challenges Faced and Solutions

- **Large File Uploads:**  
  *Challenge:* Handling large CSV files without exceeding payload limits or blocking the UI.  
  *Solution:* Used file upload actions and server-side parsing, with client-side validation for file size/type.

- **Data Table Performance:**  
  *Challenge:* Keeping the UI responsive with large datasets.  
  *Solution:* Implemented pagination and lazy loading for CSV rows.

- **User Feedback and Error Handling:**  
  *Challenge:* Ensuring users are informed of errors and actions.  
  *Solution:* Added loading states, error messages, and shadcn/ui confirmation dialogs for destructive actions.

- **Security:**  
  *Challenge:* Preventing unauthorized access to files and data.  
  *Solution:* All file operations are scoped to the authenticated user, and server-side validation is performed on uploads and edits.

---

## Libraries/Tools Chosen and Why

- **Wasp:** For full-stack structure, rapid prototyping, and built-in authentication.
- **React:** For building interactive, component-based UIs.
- **Tailwind CSS:** For utility-first, responsive, and consistent styling.
- **shadcn/ui:** For accessible, modern UI primitives (dialogs, buttons, etc.).
- **Papaparse:** For robust client-side CSV parsing.
- **Prisma:** For type-safe database access and migrations.

---
