import jQuery from 'jquery';
import 'bootstrap';
import lunr from 'lunr';

let l;

jQuery.getJSON('/assets/index.json', function(data) {
  l = lunr.Index.load(data);
})


jQuery('#searchForm').on('submit', function(e) {
  e.preventDefault();
  const searchTerm = jQuery('#searchInput').val();
  const results = l.search(searchTerm);
  const resultIds = results.map((result) => result.ref);
  jQuery('.tactile-image').each((index, value) => {
    const $el = jQuery(value);
    const id = $el.attr('id');
    if (resultIds.includes(id)) {
      $el.show();
    } else {
      $el.hide();
    }
  })
});
