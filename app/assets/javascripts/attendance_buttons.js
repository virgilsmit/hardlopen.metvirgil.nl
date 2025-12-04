document.addEventListener("turbo:load", styleAttendanceButtons);
document.addEventListener("ajax:success", styleAttendanceButtons);
document.addEventListener("DOMContentLoaded", styleAttendanceButtons);

function styleAttendanceButtons() {
  console.log('styleAttendanceButtons called');
  document.querySelectorAll("li[id^='attendance_user_']").forEach(function(li) {
    var buttons = li.querySelectorAll(".theme-btn, .attendance-btn");
    buttons.forEach(function(btn) {
      // Reset all
      btn.style.opacity = "0.25";
      btn.style.boxShadow = "none";
    });
    // Active knop zoeken
    var active = Array.from(buttons).find(function(btn) {
      return btn.getAttribute('style') && btn.getAttribute('style').includes('opacity:1');
    });
    if (active) {
      active.style.opacity = "1";
      active.style.boxShadow = "0 0 0 3px " + getComputedStyle(active).backgroundColor + "55";
    }
  });
  updateAttendanceCounts();
}

function updateAttendanceCounts() {
  // Tellen van knoppen met value 'aanwezig' en 'afwezig' die de .active klasse hebben
  var aanwezig = 0;
  var afwezig = 0;
  document.querySelectorAll("li[id^='attendance_user_']").forEach(function(li) {
    var aanwezigBtn = li.querySelector(".attendance-btn-aanwezig.active, .theme-btn-aanwezig.active");
    var afwezigBtn = li.querySelector(".attendance-btn-afwezig.active, .theme-btn-afwezig.active");
    if (aanwezigBtn) {
      aanwezig++;
    } else if (afwezigBtn) {
      afwezig++;
    }
  });
  var counts = document.getElementById("attendance_counts");
  if (counts) {
    counts.innerHTML = '<strong>Aanwezig:</strong> ' + aanwezig + ' | <strong>Afwezig:</strong> ' + afwezig;
  }
}

document.addEventListener("turbo:load", function() {
  document.querySelectorAll("form[action*='attendances']").forEach(function(form) {
    form.addEventListener("ajax:success", function() {
      window.location.reload();
    });
    form.addEventListener("submit", function() {
      setTimeout(function() { window.location.reload(); }, 500);
    });
  });
  
  // Enable/disable afwezig button based on note field input
  function setupAfwezigButtonValidation() {
    // For training_sessions/show.html.erb
    document.querySelectorAll(".afwezig-btn.inactive").forEach(function(btn) {
      var sessionId = btn.getAttribute("data-session-id");
      var noteField = document.getElementById("attendance_note_" + sessionId);
      var form = btn.closest("form");
      
      if (noteField && form) {
        function updateButtonState() {
          var noteValue = noteField.value.trim();
          if (noteValue.length > 0) {
            btn.disabled = false;
            btn.style.opacity = "1";
            btn.style.cursor = "pointer";
          } else {
            btn.disabled = true;
            btn.style.opacity = "0.35";
            btn.style.cursor = "not-allowed";
          }
        }
        
        noteField.addEventListener("input", updateButtonState);
        noteField.addEventListener("change", updateButtonState);
        updateButtonState(); // Initial state
      }
    });
    
    // For training_sessions/vandaag.html.erb
    var vandaagNoteField = document.getElementById("attendance_note_vandaag");
    var vandaagButton = document.getElementById("afwezig-btn-vandaag");
    var vandaagForm = document.getElementById("afwezig-form-vandaag");
    
    if (vandaagNoteField && vandaagButton && vandaagForm && vandaagButton.disabled) {
      function updateVandaagButtonState() {
        var noteValue = vandaagNoteField.value.trim();
        if (noteValue.length > 0) {
          vandaagButton.disabled = false;
          vandaagButton.style.opacity = "1";
          vandaagButton.style.cursor = "pointer";
        } else {
          vandaagButton.disabled = true;
          vandaagButton.style.opacity = "0.5";
          vandaagButton.style.cursor = "not-allowed";
        }
      }
      
      vandaagNoteField.addEventListener("input", updateVandaagButtonState);
      vandaagNoteField.addEventListener("change", updateVandaagButtonState);
      updateVandaagButtonState(); // Initial state
    }
  }
  
  setupAfwezigButtonValidation();
  
  // Re-run on dynamic content changes
  var observer = new MutationObserver(function(mutations) {
    setupAfwezigButtonValidation();
  });
  
  observer.observe(document.body, {
    childList: true,
    subtree: true
  });
}); 