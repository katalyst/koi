import { Controller } from "@hotwired/stimulus";

function validateInput(element) {
  const pattern = new RegExp(element.dataset.pattern);
  const value = element.value.match(pattern);
  return value && value[0];
}

function blurValidateInput(element) {
  const pattern = new RegExp(element.dataset.blurPattern);
  const value = element.value.match(pattern);
  return value && value[0];
}

function tabToNext(element, next) {
  if (element.value.length === parseInt(element.getAttribute("maxlength"))) {
    next.focus();
  }
}

class DatetimesController extends Controller {
  static targets = ["hour", "minute", "hiddenHour", "pm"];

  validateHour() {
    this.hourTarget.value = validateInput(this.hourTarget);
  }

  blurValidateHour() {
    this.hourTarget.value = blurValidateInput(this.hourTarget);
  }

  validateMinute() {
    this.minuteTarget.value = validateInput(this.minuteTarget);
  }

  blurValidateMinute() {
    this.minuteTarget.value = blurValidateInput(this.minuteTarget);
  }

  /**
   * Due to Rails multiparameter not directly supporting a 12hr input with a am/pm indication, we need to emulate on
   * the client side. Update the hidden 24-hour field in two situations:
   * - when the 12hour field is edited
   * - when the am/pm buttons are clicked
   */
  updateHiddenHourAmPm() {
    let hour = parseInt(this.hourTarget.value);

    if (isNaN(hour)) {
      this.hiddenHourTarget.value = "";
    } else {
      if (this.pmTarget.checked) {
        // 12:xx pm = 12:xx in 24 hour time
        hour = (hour % 12) + 12;
      } else {
        // 12:xx am = 00:xx in 24 hour time
        hour = hour % 12;
      }
      this.hiddenHourTarget.value = hour;
    }
  }

  tabYear() {
    tabToNext(this.yearTarget, this.hourTarget);
  }

  tabHour() {
    tabToNext(this.hourTarget, this.minuteTarget);
  }
}

export default DatetimesController;
