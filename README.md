# todo-vapor-api
API created using Vapor/Server-Side Swift to power a TODO application

## Getting Started

Setup a local database
```
docker run --name postgres -e POSTGRES_DB=vapor \
  -e POSTGRES_USER=vapor -e POSTGRES_PASSWORD=password \
  -p 5432:5432 -d postgres
  ```
  
  Generate the Xcode project
  ```
  vapor xcode -y
  ```
  
  Set the Xcode scheme to Run and run the project.
