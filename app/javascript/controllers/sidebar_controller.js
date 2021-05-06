import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = [];

  connect() {
    localStorage.setItem('mini_sidebar', localStorage.getItem('mini_sidebar') || false);
    this.display_sidebar();
  }

  toggle_sidebar(e) {
    e.preventDefault();
    localStorage.setItem('mini_sidebar', !(localStorage.getItem('mini_sidebar') === 'true'));
    this.display_sidebar();
  }

  display_sidebar() {
    if (localStorage.getItem('mini_sidebar') === 'true') {
      $('.sidebar-menu').hide();
      $('.sidebar-menu-mini').show();
      $('.content-wrapper').addClass('content-wrapper-full');
    } else {
      $('.sidebar-menu').show();
      $('.sidebar-menu-mini').hide();
      $('.content-wrapper').removeClass('content-wrapper-full');
    }
  }
}
