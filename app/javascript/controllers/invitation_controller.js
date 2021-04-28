import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['label'];

  connect() {
  }

  type_change(e) {
    $(this.labelTarget).text(['Enter', $(e.target).find('option:selected').text()].join(' '));
  }
}
