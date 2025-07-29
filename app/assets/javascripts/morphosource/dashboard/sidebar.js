// Uses Hyrax sidebar logic to collapse and open sidebar at appropriate page-widths
document.addEventListener('DOMContentLoaded', function() {
  const sidebarEl = document.querySelector('.sidebar');
  const mainContentEl = document.querySelector('.main-content');
  const sidebarToggle = document.querySelector('.sidebar-toggle');

  // Exit if the required elements for the sidebar functionality are not on the page.
  if (!sidebarEl || !mainContentEl || !sidebarToggle) {
    return;
  }

  // Create a media query to detect when the viewport is smaller than Bootstrap's 'md' breakpoint.
  // Bootstrap 4's 'md' breakpoint is 768px. This query matches screens *smaller* than that.
  const mediaQuery = window.matchMedia('(max-width: 767.98px)');

  // This function is called when the breakpoint is crossed.
  const handleBreakpointChange = function(e) {
    // e.matches is true if the screen is SMALLER than the breakpoint
    if (e.matches) {
      // If the screen is small and the sidebar is maximized, collapse it.
      if (sidebarEl.classList.contains('maximized')) {
        sidebarEl.classList.remove('maximized');
        mainContentEl.classList.remove('maximized');
      }
    } else {
      // If the screen is large and the sidebar is NOT maximized, expand it.
      // This ensures the sidebar is open by default on larger screens.
      if (!sidebarEl.classList.contains('maximized')) {
        sidebarEl.classList.add('maximized');
        mainContentEl.classList.add('maximized');
      }
    }
  };

  // Listen for changes in the viewport width relative to the breakpoint.
  mediaQuery.addEventListener('change', handleBreakpointChange);

  // Run the check once on initial page load to set the correct state.
  handleBreakpointChange(mediaQuery);
});