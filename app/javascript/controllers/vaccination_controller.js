import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['showModal', 'modal', 'formField', 'append', 'vaccineCheckbox', 'ids', 'form', 'data'];

  connect() {
    if ($(this.showModalTarget).val() === 'true') {
      $(this.modalTarget).modal();
    }
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

  submit(e) {
    var emails = $(this.dataTargets).map(function () {
      return $(this).val()
    }).toArray().join(', ');
    if (!confirm(['You have asked for your vaccination record to be shared with ', emails, '. Please confirm agreement with this statement: I understand that my personal health information specified will be securely sent to the above mentioned party.'].join(''))) {
      e.preventDefault();
      this.reset(e);
    }
  }
}
