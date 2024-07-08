## Kindergarten Database Project
- Author: Tomáš Dolák, Monika Zahradníková
- Login: [xdolak09](https://www.vut.cz/lide/tomas-dolak-247220), xzahra33
- Email: <xdolak09@stud.fit.vutbr.cz>, <xzahra33@stud.fit.vutbr.cz>

### Project Overview
The aim of this project is to design and implement a relational database for a kindergarten.
The project is divided into four parts and all SQL scripts must be compatible with Oracle 12c and support repeated executions, allowing for the deletion and recreation or direct overwriting of database objects and data.

### Project Parts
#### Part 1 - Data Model (ERD) and Use Case Model

- **Data Model**: An ER diagram capturing the data structure requirements in UML class diagram notation or Crow's Foot notation. The model must include at least one generalization/specialization relationship.

- **Use Case Model**: A UML use case diagram representing the application's functionality requirements using the designed database model.

- **Documentation**: A document containing the above models and a brief description of the data model, explaining the significance of each entity and relationship set.

#### Part 2 - SQL Script for Creating Database Schema Objects

- **SQL Script**: A script that creates the fundamental objects of the database schema, including tables with integrity constraints (primary and foreign keys) and sample data.

- **Requirements**:
  - At least one column with a special value constraint (e.g., birth number, insurance number).
  - Proper implementation of the generalization/specialization relationship for a relational database.
  - Automatic generation of primary key values using sequences.
  - Explanation of the chosen method for converting the generalization/specialization relationship in SQL comments.

#### Part 3 - SQL Script with SELECT Queries
- **SQL Script**: A script that first creates the basic database schema objects and fills the tables with sample data (same as in Part 2), followed by several SELECT queries.

- **Requirements**:
  - At least two queries joining two tables.
  - One query joining three tables.
  - Two queries with GROUP BY and aggregate functions.
  - One query with the EXISTS predicate.
  - One query with the IN predicate and a nested select (not a constant set).
  - Comments explaining the purpose and functionality of each query.

#### Part 4 - SQL Script for Advanced Database Schema Objects

- **SQL Script**: A script that first creates the basic database schema objects and fills the tables with sample data (same as in Part 2), then defines or creates advanced constraints or objects as specified.

- **Requirements**:
  - Two non-trivial database triggers with demonstration.
  - Two non-trivial stored procedures with demonstration, including the use of a cursor, exception handling, and variable types referencing table columns or rows.
  - Creation of at least one index to optimize query processing, with an explanation of its use and comparison of query plans before and after index creation.
  - Use of EXPLAIN PLAN for a query with a join, aggregate function, and GROUP BY clause, including an explanation of the query execution plan and suggested optimization methods.
  - Definition of access rights for the second team member.
  - Creation of a materialized view owned by the second team member using tables defined by the first member, with demonstration queries.
  - One complex SELECT query using the WITH clause and CASE operator, with comments explaining the data retrieved.