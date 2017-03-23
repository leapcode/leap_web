/*
 * Buttons.js
 *
 * Use bootstrap loading state after submitting a form.
 *
 * Some form inputs are validaded before the submission
 * so triggering loading state on click events is not a
 * good idea. If the validation fails the errors will
 * be displayed but the button would be in loading state.
 *
 * We used to trigger it based on form submission but
 * we have a few forms that contain multiple buttons.
 * So now we mark the buttons as clicked on click and
 * put the clicked button into loading state on submit.
 *
 */

(function() {
  markAsClicked = function () {
    var btn = $(this)
    btn.addClass('clicked')
    setTimeout(function () {
      btn.removeClass('clicked')
    }, 1000)
  };

  markAsLoading = function(submitEvent) {
    var form = submitEvent.target;
    var validations = form.ClientSideValidations

    if ( ( typeof validations === 'undefined' ) ||
         $(form).isValid(validations.settings.validators) ) {
      $(form).addClass('submitted')
      // bootstrap loading state:
      $(form).find('.btn.clicked[type="submit"]').button('loading');
    }
  };

  $(document).ready(function() {
    $('form').submit(markAsLoading);
    $('.btn[type="submit"]').click(markAsClicked);
  });

}).call(this);
