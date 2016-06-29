(function() {
  'use strict';

  function setHtnTime() {
    var millisecondsLeft = (new Date("Sept. 16 2016, 15:00")) - (new Date());
    var hoursLeft = Math.round(millisecondsLeft / 1000 / 60 / 60);
    var daysLeft = Math.floor(hoursLeft / 24);

    $("#htn-hours").text(hoursLeft - (daysLeft * 24));
    $("#htn-days").text(daysLeft);
  }

  $(function() {
    $("#center-above").prepend("<h2><span id='htn-days'></span> days and <span id='htn-hours'></span> hours until Hack the North\!</h2>");

    setHtnTime();
    setInterval(setHtnTime, 1000);
  })
})();
