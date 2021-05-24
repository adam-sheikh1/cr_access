import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['showModal', 'modal', 'formField', 'append', 'vaccineCheckbox', 'ids'];

  connect() {
    if ($(this.showModalTarget).val() === 'true') {
      $(this.modalTarget).modal();
    }
  }

  add_field(e) {
    e.preventDefault();

    var to_append = $(this.formFieldTargets).last().clone().find("input, select").val('').end();
    to_append.find('.field_with_errors').removeClass('field_with_errors');
    to_append.find('small').text('');
    $(this.appendTarget).append(to_append);
  }

  reset(e) {
    e.preventDefault();

    $(this.formFieldTargets).not(':eq(0)').remove();
    $(this.formFieldTargets).find('.field_with_errors').removeClass('field_with_errors');
    $(this.formFieldTargets).find('small').text('');
    $(this.formFieldTargets).find('input, select').val('');
  }

  show_modal() {
    if ($(this.vaccineCheckboxTargets).filter(':checked').length === 0) {
      alert('Please select a vaccine to share');
    } else {
      $(this.modalTarget).modal('show');
      $(this.idsTarget).val($(this.vaccineCheckboxTargets).filter(':checked').map(function () {
        return $(this).val();
      }).toArray());
    }
  }
}
