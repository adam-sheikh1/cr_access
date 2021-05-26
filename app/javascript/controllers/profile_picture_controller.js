import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['form'];

  update_pfp() {
    $(this.formTarget).submit();
  }
}
