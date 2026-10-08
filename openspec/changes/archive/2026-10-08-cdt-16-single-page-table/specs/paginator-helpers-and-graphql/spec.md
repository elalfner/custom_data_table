## ADDED Requirements

### Requirement: PaginatorInfo Single-Page Factory Constructor
`PaginatorInfo` SHALL provide a `singlePage` factory constructor that constructs pagination metadata representing a complete, single-page dataset.

#### Scenario: Instantiate PaginatorInfo with singlePage factory
- **WHEN** `PaginatorInfo.singlePage(total: 42)` is called
- **THEN** the returned instance has `currentPage == 1`, `lastPage == 1`, `perPage == 42`, `total == 42`, `count == 42`, and `hasMorePages == false`

#### Scenario: Instantiate PaginatorInfo with singlePage factory for zero items
- **WHEN** `PaginatorInfo.singlePage(total: 0)` is called
- **THEN** the returned instance has `currentPage == 1`, `lastPage == 1`, `perPage == 0`, `total == 0`, `count == 0`, and `hasMorePages == false`

### Requirement: GraphQL Lighthouse Integration Documentation
The package documentation in `README.md` SHALL provide explicit instructions and examples for integrating `CustomDataTable` with GraphQL Lighthouse and `graphql_codegen`.

#### Scenario: Developer integrates Lighthouse PaginatorInfo fragment
- **WHEN** a developer consults `README.md` for GraphQL Lighthouse integration
- **THEN** they find an extension snippet demonstrating mapping `Fragment$Paginator` JSON to `PaginatorInfo.fromJson(toJson())` and an example of non-paginated table usage
