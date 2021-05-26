import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['form'];

  update_profile_picture() {
    $(this.formTarget).submit();
  }
}
