const parse = require('csv-parse');
const lunr = require('lunr');
const stdin = process.stdin;
const stdout = process.stdout;
const buffer = [];

stdin.resume();
stdin.setEncoding('utf8');

stdin.on('data',  (data) => {
  buffer.push(data);
});

stdin.on('end', () => {
  const stuff = parse(buffer.join(''), {
    columns: true,
    skip_empty_lines: true,
  }, function(err, output) {
    // console.log(output);
    const idx = lunr(function () {
      const that = this;
      that.ref('uuid');
      Object.keys(output[0]).forEach((field) => {
        this.field(field)
      }, this);
      output.forEach((doc) => {
        // console.log(doc)
        this.add(doc);
      }, this)
    });
    stdout.write(JSON.stringify(idx))
  })
  // debugger;
  // console.log(buffer);
  // console.log(stuff);
  // const documents = 
});
