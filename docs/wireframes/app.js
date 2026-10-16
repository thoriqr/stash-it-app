/* ==========================================================================
   Stash It — wireframe prototype behaviours
   --------------------------------------------------------------------------
   Vanilla JS, no libraries, no network. Classic script (not a module) so it
   runs from file:// without a server.

   NOTHING here performs a real action: no network, no clipboard, no storage,
   no auth, no URL submission. Every interaction only reveals a different
   static representation of a documented state.
   ========================================================================== */
(function () {
  'use strict';

  var VP_PRESETS = ['fluid', 'narrow', 'portrait', 'landscape', 'tablet', 'desktop'];

  /* ---- viewport preset -------------------------------------------------- */
  function applyPreset(name) {
    if (VP_PRESETS.indexOf(name) === -1) { name = 'portrait'; }
    document.body.setAttribute('data-vp', name);

    var btns = document.querySelectorAll('[data-vp-set]');
    for (var i = 0; i < btns.length; i++) {
      var b = btns[i];
      var on = b.getAttribute('data-vp-set') === name;
      b.setAttribute('aria-pressed', on ? 'true' : 'false');
      if (on) { b.classList.add('is-active'); } else { b.classList.remove('is-active'); }
    }
    var readout = document.getElementById('vp-readout');
    if (readout) { readout.textContent = name; }
    try { localStorage.setItem('stash.wf.vp', name); } catch (e) { /* file:// may block */ }
  }

  /* ---- annotations ------------------------------------------------------ */
  function setAnnotations(on) {
    document.body.setAttribute('data-ann', on ? 'on' : 'off');
    var btns = document.querySelectorAll('[data-ann-toggle]');
    for (var i = 0; i < btns.length; i++) {
      btns[i].setAttribute('aria-pressed', on ? 'true' : 'false');
      btns[i].textContent = on ? 'Annotations: ON' : 'Annotations: OFF';
    }
    try { localStorage.setItem('stash.wf.ann', on ? 'on' : 'off'); } catch (e) {}
  }

  /* ---- state variant switch --------------------------------------------
     Groups of siblings marked [data-variant-group]; only the child whose
     data-variant matches the group's current state is shown.                 */
  function setVariant(groupName, variant) {
    var groups = document.querySelectorAll('[data-variant-group="' + groupName + '"]');
    for (var g = 0; g < groups.length; g++) {
      groups[g].setAttribute('data-current', variant);
      var kids = groups[g].querySelectorAll('[data-variant]');
      for (var k = 0; k < kids.length; k++) {
        var on = kids[k].getAttribute('data-variant') === variant;
        if (on) { kids[k].classList.remove('is-hidden'); }
        else { kids[k].classList.add('is-hidden'); }
      }
    }
    var btns = document.querySelectorAll('[data-variant-set="' + groupName + '"]');
    for (var b = 0; b < btns.length; b++) {
      btns[b].setAttribute('aria-pressed',
        btns[b].getAttribute('data-variant-val') === variant ? 'true' : 'false');
    }
  }

  /* ---- sheets & dialogs ------------------------------------------------- */
  function closeAllOverlays() {
    var open = document.querySelectorAll('.sheetwrap:not(.is-hidden)');
    for (var i = 0; i < open.length; i++) { open[i].classList.add('is-hidden'); }
  }

  function openOverlay(id) {
    var el = document.getElementById(id);
    if (el) { el.classList.remove('is-hidden'); }
  }
  function closeOverlay(id) {
    var el = document.getElementById(id);
    if (el) { el.classList.add('is-hidden'); }
  }

  /* ---- delegated click handling ------------------------------------------ */
  document.addEventListener('click', function (ev) {
    var t = ev.target;
    if (!t || !t.closest) { return; }

    var vpBtn = t.closest('[data-vp-set]');
    if (vpBtn) { applyPreset(vpBtn.getAttribute('data-vp-set')); return; }

    if (t.closest('[data-ann-toggle]')) {
      setAnnotations(document.body.getAttribute('data-ann') !== 'on');
      return;
    }

    var vBtn = t.closest('[data-variant-set]');
    if (vBtn) {
      setVariant(vBtn.getAttribute('data-variant-set'), vBtn.getAttribute('data-variant-val'));
      return;
    }

    var openBtn = t.closest('[data-open]');
    if (openBtn) { openOverlay(openBtn.getAttribute('data-open')); return; }

    var closeBtn = t.closest('[data-close]');
    if (closeBtn) {
      var target = closeBtn.getAttribute('data-close');
      if (target === 'all') { closeAllOverlays(); }
      else { closeOverlay(target); }
      return;
    }

    if (t.closest('[data-scrim]')) { closeAllOverlays(); return; }
  });

  /* ---- keyboard: Escape closes any open overlay ------------------------- */
  document.addEventListener('keydown', function (ev) {
    if (ev.key === 'Escape') { closeAllOverlays(); }
  });

  /* ---- init -------------------------------------------------------------- */
  function init() {
    var vp = 'portrait', ann = 'off';
    try {
      vp = localStorage.getItem('stash.wf.vp') || 'portrait';
      ann = localStorage.getItem('stash.wf.ann') || 'off';
    } catch (e) {}
    setAnnotations(ann === 'on');
    applyPreset(vp);

    // Groups start from their declared default so markup is meaningful without JS.
    var groups = document.querySelectorAll('[data-variant-group]');
    for (var i = 0; i < groups.length; i++) {
      var g = groups[i];
      if (!g.getAttribute('data-current')) {
        var first = g.querySelector('[data-variant]');
        g.setAttribute('data-current', first ? first.getAttribute('data-variant') : '');
      }
    }
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();