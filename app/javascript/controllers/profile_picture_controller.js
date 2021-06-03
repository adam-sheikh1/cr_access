import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['form', 'input'];

  update_profile_picture() {
    $(this.formTarget).submit();
  }

  click_file_input() {
    $(this.inputTarget).trigger('click');
  }
}
