$(document).ready(function() {
  // Only load for media list media works table
  if (document.querySelector("div.media-list-results")) {
    class MediaList {
      constructor(html) {
        this.html = html;
        this.activeRow = this.html.querySelector("tr.previewable.view-active");
        if (this.activeRow) this.#loadMediaView({ scrollWindow: true });
        
        this.#activateListeners();
      }

      // Row (tr.previewable) currently viewed, has special UI highlighting
      #activeRow = null;
      get activeRow() {
        return this.#activeRow;
      }
      set activeRow(activeRow) {
        this.#activeRow = activeRow;

        if (activeRow) {
          // Reset hide and show for all rows
          this.html.querySelectorAll("tr.previewable").forEach((row) => {
            row.classList.remove("view-active");
            row.querySelector(".currently-viewing").classList.add("hide");
            row.querySelector(".view-media").classList.remove("hide");
          });

          // Hide and show for active row
          activeRow.classList.add("view-active");
          activeRow.querySelector(".currently-viewing").classList.remove("hide");
          activeRow.querySelector(".view-media").classList.add("hide");
        }   
      }

      // UI updates and AJAX call for media view load
      #loadMediaView({ callAjax = true, scrollWindow = false } = {}) {
        // Move viewer up or down 
        this.#transformViewerYPosition(scrollWindow);

        // Add loading UI overlay
        $('.preview-body').loader({ imgUrl: "/loading32x32.gif "});

        // Enable or disable prev/next buttons
        this.#togglePrevNextButtonState();

        // Call AJAX media view load
        if (callAjax) $.get(
          `/media_lists/${this.activeRow.dataset.collectionId}/preview/${this.activeRow.dataset.documentId}`
        );
      }

      // Move viewer down the page for lower table rows, possibly scrolling window as well
      #transformViewerYPosition(scrollWindow) {
        // Only transform or scroll at large screen widths (e.g., in side-by-side UI)
        if (window.matchMedia("(min-width: 992px)").matches) {
          const allRows = this.activeRow.parentNode.children;
          const rowIndex = Array.prototype.indexOf.call(allRows, this.activeRow);
          const viewer = this.html.querySelector(".preview-body")
    
          if (rowIndex && rowIndex > 4) {
            // Retain original transform
            const oldTransform = viewer.style.transform;
            const oldYPixels = oldTransform ? oldTransform.replace(/[^\d.]/g, '') : 0;
    
            // Calc new transform and apply
            const newYPixels = this.activeRow.offsetHeight * (rowIndex + 1) - viewer.offsetHeight;
            viewer.style.transform = `translateY(${newYPixels}px)`;
    
            if (scrollWindow) {
              window.scrollBy(0, newYPixels - oldYPixels);
            }      
          } else {
            viewer.style.transform = null;
          }
        }
      }

      #togglePrevNextButtonState() {
        if (this.#canEnablePrevButton()) {
          this.html.querySelector("a.previous").classList.remove("disabled");
        } else {
          this.html.querySelector("a.previous").classList.add("disabled");
        }
        if (this.#canEnableNextButton()) {
          this.html.querySelector("a.next").classList.remove("disabled");
        } else {
          this.html.querySelector("a.next").classList.add("disabled");
        }
      }

      #activateListeners() {
        // Load view from row click
        const rowClickListener = (event) => {
          // ignore if row is active or if target is interactable in some other ways
          if (
            !event.currentTarget.classList.contains("view-active") &&
            !event.target.matches("a, a *, button, i, input")
          ) {
            this.activeRow = event.currentTarget;
            this.#loadMediaView();
          }
        };
        this.html.querySelectorAll("tr.previewable").forEach((row) => {
          row.addEventListener("click", rowClickListener);
        });

        // View button (for keyboard navigation)
        const viewButtonListener = (event) => {
          this.activeRow = event.currentTarget.closest("tr.previewable");
          this.#loadMediaView();
        };
        this.html.querySelectorAll("a.view-media.dynamic").forEach((btn) => {
          btn.addEventListener("click", viewButtonListener);
        });

        // Initial media view button
        this.html.querySelector(".view-initial-media")?.addEventListener("click", () => {
          this.activeRow = this.html.querySelector("tr.previewable");
          this.#loadMediaView();
        });

        // Load view from previous and next buttons by clicking view button
        const prevNextListener = (event) => {
          event.preventDefault();
          const button = event.currentTarget;

          const oldRow = this.html.querySelector("tr.view-active");
          let newRow = null;
          if (button.classList.contains("previous")) {
            newRow = this.activeRow.previousElementSibling;
          } else if (button.classList.contains("next")) {
            newRow = this.activeRow.nextElementSibling;
          }

          if (oldRow) {
            if (newRow) {
              this.activeRow = newRow;
              this.#loadMediaView({ scrollWindow: true });
            } else if (button.classList.contains("next") && this.#nextPageExists()) {
              // Special case: on final row with next page, move to next page
              const url = new URL(document.querySelector("a[rel='next']").href);
              // if (!url.searchParams.get("load")) url.searchParams.append("load", "true");
              window.location = url;
            } else if (button.classList.contains("previous") && this.#prevPageExists()) {
              // Special case: on first row with prev page, move to prev page
              const url = new URL(document.querySelector("a[rel='prev']").href);
              // if (!url.searchParams.get("load")) url.searchParams.append("load", "true");
              window.location = url;
            }
          }
        }
        this.html.querySelectorAll("a.previous, a.next").forEach((btn) => {
          btn.addEventListener("click", prevNextListener);
        });
      }

      // Utility methods

      // Is there an active row that is not the first possible row?
      #canEnablePrevButton() {
        return (
          (this.activeRow && this.activeRow != this.activeRow.parentNode.firstElementChild) || 
          this.#prevPageExists()
        );
      }

      // Is there an active row that is not the last row OR is there a next page button?
      #canEnableNextButton() {
        return (
          (this.activeRow && this.activeRow != this.activeRow.parentNode.lastElementChild) || 
          this.#nextPageExists()
        );
      }

      #prevPageExists() {
        const prevPageButton = document.querySelector("a[rel='prev']");
        return prevPageButton && prevPageButton.getAttribute("href") != "#";
      }

      #nextPageExists() {
        const nextPageButton = document.querySelector("a[rel='next']");
        return nextPageButton && nextPageButton.getAttribute("href") != "#";
      }
    }

    new MediaList(document.querySelector("div.media-list-results"));
  }
});