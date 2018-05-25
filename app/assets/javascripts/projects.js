$(function () {

  // Toggle the display of the specific week selections
  $(".project-form input[name='project[any_week]']").change(function() {
    var any_week = $(this).val() == 'true';
    if (any_week) {
      $(".project-form .specific-week-container").collapse('hide');
      $(".project-form input[name='project[week_1]']").val( ['true']);
      $(".project-form input[name='project[week_2]']").val(['true']);
      $(".project-form input[name='project[week_3]']").val(['true']);
      $(".project-form input[name='project[week_4]']").val(['true']);
    } else {
      $(".project-form .specific-week-container").collapse('show');
      $(".project-form input[name='project[week_1]']").val( ['false']);
      $(".project-form input[name='project[week_2]']").val(['false']);
      $(".project-form input[name='project[week_3]']").val(['false']);
      $(".project-form input[name='project[week_4]']").val(['false']);
    }
  });

});
