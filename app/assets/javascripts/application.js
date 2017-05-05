// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require bootstrap-sprockets
//= require metisMenu/jquery.metisMenu.js
//= require pace/pace.min.js
//= require slimscroll/jquery.slimscroll.min.js
//= require toastr/toastr.min.js
//= require jasny/jasny-bootstrap.min.js
//= require select2/select2.full.min.js
//= require datepicker/bootstrap-datepicker.js
//= require sweetalert/sweetalert.min.js
//= require showdown/showdown.min.js
//= require chartJs/Chart.bundle.min.js
//= require knockoutjs/knockout-3.4.2.js
//= require clockpicker/clockpicker.js
//= require_tree .

$(function() {

  $('[data-toggle="tooltip"]').tooltip();

  toastr.options = {
    "closeButton": true,
    "debug": true,
    "progressBar": true,
    "preventDuplicates": false,
    "positionClass": "toast-top-right",
    "onclick": null,
    "showDuration": "400",
    "hideDuration": "1000",
    "timeOut": "2000",
    "extendedTimeOut": "1000",
    "showEasing": "swing",
    "hideEasing": "linear",
    "showMethod": "fadeIn",
    "hideMethod": "fadeOut"
  };

  $('.toastr-message').each(function() {
    window["toastr"][$(this).attr('data-toastr-type')]($(this).text());
  });

  $('.date.days .datepicker').datepicker({
    format: "dd/mm/yyyy",
    startView: "days",
    todayBtn: true,
    todayHighlight: true,
    keyboardNavigation: false,
    forceParse: false,
    autoclose: true,
    weekStart: 1,
    defaultViewDate: { year: 2017, month: 6, day: 1 }
  });

  $('.clockpicker').clockpicker();

  function warn(e) {
    e.preventDefault();
    var source = $(this);
    swal(
      {
        title: "Warning",
        text: "You may not be able to undo this action. Are you sure you want to continue?",
        type: "warning",
        showCancelButton: true,
        cancelButtonText: "No, cancel",
        confirmButtonColor: "#DD6B55",
        confirmButtonText: "Yes, continue",
        closeOnConfirm: false,
        html: false
      },
      function (confirmed) {
        if (confirmed) {
          source.off(e.type, warn);
          source.trigger(e.type);
        }
      });
  }

  $("form[data-warn]").submit(warn);
  $("button[data-warn]").click(warn);

  // Showdown (markdown) live preview
  var converter = new showdown.Converter();
  $('#showdown-editor').keyup(function convert() {
    $('#showdown-preview').html(converter.makeHtml($(this).val()));
  });
  $('#showdown-editor').keyup();

})
