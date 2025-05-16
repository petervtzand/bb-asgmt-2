import './App.css';
import { useState, useEffect } from 'react';

export function TableNameButtons({ handleSetSelectedTableNameButton, selectedTableName }) {
  const [tableNames, setTableNames] = useState([]);

  useEffect(() => {
    fetch('http://localhost:4001/read_file')
      .then(() => fetch('http://localhost:4000/api/table_names'))
      .then((res) => {
        return res.json();
      })
      .then((data) => {
        setTableNames(data['table_names']);
      });
  }, []);

  return (
    <div>
      {tableNames.map((tableName) => (
        <button key={tableName} className={"bb-button" + (tableName === selectedTableName ? " button-active" : "")} onClick={() => handleSetSelectedTableNameButton(tableName)}>
          {tableName}
        </button>
      ))}

    </div>
  )
}

export function ShowTableRows({ tableName }) {
  const [tableData, setTableData] = useState<any[]>([]);
  const [tableColumns, setTableColumns] = useState<string[]>([]);

  useEffect(() => {
    fetch(`http://localhost:4000/api/${tableName}`)
      .then((res) => res.json()).catch(() => null)
      .then((data) => {
        if (data) {
          setTableData(data[tableName])
          setTableColumns(Object.keys(data[tableName][0]));
        } else {
          setTableData([])
          setTableColumns([])
        }
      });
  }, [tableName]);

  let columnHeaders = tableColumns.map((tableName) =>
    <th>{tableName}</th>
  )

  function getTableRow(tableColumns: any, row: any) {
    return (
      <tr>{tableColumns.map(function (columnName: string) {
        return <td>{row[columnName]}</td>;
      })}</tr>
    )
  }

  // Fallback when no data found
  if (!tableData.length) {
    return (<p>No data found</p>)
  }

  return (
    <div className="rows-wrapper">
      <table>
        <thead><tr>{columnHeaders}</tr></thead>
        <tbody>{tableData.map((row) => getTableRow(tableColumns, row))}</tbody>
      </table>
    </div>
  )
}


function App() {

  const [selectedTableName, setSelectedTableName] = useState<string | null>(null);

  function handleSetSelectedTableNameButton(value: string) {
    setSelectedTableName(value)
  }

  return (
    <div className="App">
      <header className="App-header">
        <img src="https://www.bettyblocks.com/hubfs/logo-red.svg" className="App-logo" alt="logo" />

        <p>
          Choose a model to query the results from the backend.
        </p>
        <TableNameButtons
          handleSetSelectedTableNameButton={handleSetSelectedTableNameButton}
          selectedTableName={selectedTableName}
        />
        <p>Selected table name: {selectedTableName || 'No table selected'}</p>

        {selectedTableName && <ShowTableRows tableName={selectedTableName} />}

      </header>

    </div>
  );
}

export default App;
<link rel="shortcut icon" href="https://www.bettyblocks.com/hubfs/betty_favicon.png"></link>
