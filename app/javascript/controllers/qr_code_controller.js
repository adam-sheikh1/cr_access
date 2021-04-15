import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['image'];
  connected = true;

  connect() {
    if (this.hasImageTarget) {
      this.bind_update_code();
    }
  }

  bind_update_code() {
    var obj = this;
    setTimeout(function () {
      obj.update_code(parseInt(obj.imageTarget.dataset.refreshInterval));
    }, parseInt(this.imageTarget.dataset.timeRemaining) * 1000);
  }

  update_code(interval) {
    var obj = this;
    if (obj.connected) {
      $.ajax({
        url: this.imageTarget.dataset.refreshUrl,
        method: 'GET',
        success: function (options) {
          $(obj.imageTarget).attr('src', options.image);
          setTimeout(function () {
            obj.update_code(interval);
          }, interval * 1000);
        }
      });
    }
  }

  disconnect() {
    this.connected = false;
  }
}
