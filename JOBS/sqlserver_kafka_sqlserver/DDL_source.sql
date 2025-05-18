USE [company]
GO

CREATE TABLE depts (
    id INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(85) NULL
);

CREATE TABLE emps (
    id INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    dept_id INT NOT NULL,
    first_name VARCHAR(85) NULL,
    last_name VARCHAR(85) NULL,
    hired_at DATETIME NULL DEFAULT GETDATE(),

    CONSTRAINT FK_emps_depts
        FOREIGN KEY (dept_id)
        REFERENCES depts(id)
);

CREATE INDEX IX_emps_dept_id ON emps(dept_id);

-- Enable CDC on the table
EXEC sys.sp_cdc_enable_table
    @source_schema = N'dbo',
    @source_name = N'depts',
    @role_name = NULL;

EXEC sys.sp_cdc_enable_table
    @source_schema = N'dbo',
    @source_name = N'emps',
    @role_name = NULL;



INSERT INTO depts (name) VALUES ('HR');
INSERT INTO depts (name) VALUES ('Finance');
INSERT INTO depts (name) VALUES ('Operation');
INSERT INTO depts (name) VALUES ('Admin');
INSERT INTO depts (name) VALUES ('IT');
INSERT INTO depts (name) VALUES ('Audit');

INSERT INTO emps (dept_id,first_name,last_name) VALUES (5,'larry','loi');
INSERT INTO emps (dept_id,first_name,last_name) VALUES (1,'john','doe');