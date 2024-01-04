// Previous requests page JS listeners
// Modal-specific listeners are in modal.js

$(document).ready(function() {
  if ($('div.itemtable.previous_requests').length) { // check if the page is dashboard my previous requests
    // Select all requests
    document.querySelector('#select-all-reqs').addEventListener('click', event => {
      event.preventDefault();
      document.querySelectorAll('tr').forEach(row => selRow(row));
    });

    // Select no requests
    document.querySelector('#select-no-reqs').addEventListener('click', event => {
      event.preventDefault();
      document.querySelectorAll('tr').forEach(row => unselRow(row));
    });

    // Select requests matching work
    document.querySelectorAll('.select-all-reqs-work').forEach(element => {
      element.addEventListener('click', event => {
        event.preventDefault();
        const work = event.currentTarget.closest('tr')?.dataset.work;
        if (work) document.querySelectorAll(`tr[data-work='${work}']`).forEach(row => selRow(row));
      })
    });

    // Select requests matching object
    document.querySelectorAll('.select-all-reqs-object').forEach(element => {
      element.addEventListener('click', event => {
        event.preventDefault();
        const object = event.currentTarget.closest('tr')?.dataset.object;
        if (object) document.querySelectorAll(`tr[data-object='${object}']`).forEach(row => selRow(row));
      })
    });

    // Select requests matching user
    document.querySelectorAll('.select-all-reqs-user').forEach(element => {
      element.addEventListener('click', event => {
        event.preventDefault();
        const user = event.currentTarget.closest('tr')?.dataset.requestUser;
        if (user) document.querySelectorAll(`tr[data-request-user='${user}']`).forEach(row => selRow(row));
      })
    });

    // Select requests matching user and intended use
    document.querySelectorAll('.select-all-reqs-use').forEach(element => {
      element.addEventListener('click', event => {
        event.preventDefault();
        const targetRow = event.currentTarget.closest('tr');
        const user = targetRow?.dataset.requestUser;
        const use = targetRow?.querySelector('td.intended-use')?.innerText;
        if (user && use) {
          // Rows matching user
          document.querySelectorAll(`tr[data-request-user='${user}']`).forEach(row => {
            // Does row match use?
            const rowUse = row.querySelector('td.intended-use')?.innerText;
            if (rowUse && use == rowUse) selRow(row);
          });
        }
      })
    });
  }

  // Select a row AKA check row checkbox
  const selRow = function(row) {
    const checkbox = row.querySelector('.batch_document_selector');
    if (checkbox) checkbox.checked = true;
  }

  // Unselect a row AKA uncheck row checkbox
  const unselRow = function(row) {
    const checkbox = row.querySelector('.batch_document_selector');
    if (checkbox) checkbox.checked = false;
  }

});
