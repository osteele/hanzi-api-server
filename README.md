# Hanzi API Server

This is a Node.js API server that searches a SQLite database for character
decompositions. It provides a single route that accepts a Hanzi character as a
parameter and returns the decomposition of that character.

## Getting Started

To get started, you'll need to install Node.js and the required dependencies.
You can do this by running:

```sh
yarn install
```

This will install the required packages specified in the `package.json` file,
including `express`, `sqlite3`, and `cors`.

You'll also need to create a SQLite database from a TSV file. You can do this by
running the `create-db.sh` script:

```sh
yarn run createdb
```

This will download the TSV file from
<https://commons.wikimedia.org/wiki/User:Artsakenos/CCD-TSV>, if it has been
updated since the last download; create a new SQLite database file
(`./db/decompositions.sqlite`); and import the data from the TSV file into the
`decompositions` table.

Once you've installed the dependencies and created the database, you can start
the server by running:

```sh
yarn start
```

This will start the server on port 3100. You can then access the API
endpoint at `http://localhost:3100/decomposition/:character`, where `:character`
is a Hanzi character.

`yarn start` defaults to a different port from the webdev default (3000), so
 that the dev API server and dev web server can be run at the same type with
 defaults

## API Endpoint

The server provides a single API endpoint at `/decomposition/:character`, where
`:character` is a Hanzi character. The endpoint accepts GET requests and returns
the decomposition of the character in JSON format.

For example, to get the decomposition of the character "好", you can make a GET
request to `http://localhost:3100/decomposition/好`. This will return a JSON
object with the character and its decomposition:

```json
{
  component: "好",
  strokes: 6,
  decompositionType: "吅",
  leftComponent: "女",
  leftStrokes: 3,
  rightComponent: "子",
  rightStrokes: 3,
  signature: "VND",
  notes: "/",
  section: "女",
}
```

See [the Wikipedia
page](https://commons.wikimedia.org/wiki/Commons:Chinese_characters_decomposition)
for a description of these properties.

If the character is not found in the database, the server will return a 404 Not
Found response.

## Configuration

The server can be configured by setting theese environment variables:

- `CORS_ORIGINS` (default empty) -- comma-separate list of URLs or domains for
  CORS access. Leave unset to allow all domains.
- `DATABASE_PATH` (`data/decompositions.sqlite`) -- the path to the SQLite
  database file
- `HOME_PAGE_REDIRECT_URL` (empty) -- visiting the site root redirects to this page
- `PORT` (`3010`) -- HTTP port

## Acknowledgements

The server uses the public domain Chinese character decomposition data described
[here](https://commons.wikimedia.org/wiki/Commons:Chinese_characters_decomposition).

The `yarn createdb` command downloads this data from the Wikipedia into the
`./data` directory, and uses it to construct a Sqlite database file in that
directory.

## License

This project is licensed for non-commercial use under the GNU Affero Gernal
Public License - see the [LICENSE](LICENSE) file for details.
