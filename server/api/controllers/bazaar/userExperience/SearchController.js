const { Client } = require('@elastic/elasticsearch');
const client = new Client({ node: 'http://localhost:9200' });

exports.performSearch = async (req, res) => {
  try {
    const { query, sort, filter } = req.query;

    const searchParams = {
      index: 'assets',
      body: {
        query: {
          bool: {
            must: [
              { match: { title: query } },
              ...Object.entries(filter || {}).map(([field, value]) => ({ term: { [field]: value } })),
            ],
          },
        },
        sort: sort ? [sort] : undefined,
      },
    };

    const { body } = await client.search(searchParams);

    const results = body.hits.hits.map(hit => hit._source);

    res.json(results);
  } catch (error) {
    res.status(500).send(error.message);
  }
};