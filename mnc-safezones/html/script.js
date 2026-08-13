let currentZones = [];
let pendingDeleteId = null;
let pendingDeleteName = '';

// ── Message listener from client.lua ────────────────────────────────────────
window.addEventListener('message', (event) => {
    const { action } = event.data;

    if (action === 'openMenu') {
        currentZones = event.data.zones || [];
        document.getElementById('container').classList.remove('hidden');
        renderZones();
    }

    if (action === 'setPoint') {
        document.getElementById('cx').value = event.data.center_x;
        document.getElementById('cy').value = event.data.center_y;
        document.getElementById('cz').value = event.data.center_z;
        const hint = document.getElementById('coordHint');
        hint.innerHTML = `✅ Coordinates set: <strong>${event.data.center_x}, ${event.data.center_y}, ${event.data.center_z}</strong>`;
        hint.style.color = '#00ff99';
    }

    // ── Zone HUD ──────────────────────────────────────────────────────────
    if (action === 'showZoneHUD') {
        const hud    = document.getElementById('zoneHUD');
        const icon   = document.getElementById('hudIcon');
        const status = document.getElementById('hudStatus');

        document.getElementById('hudName').textContent = event.data.name;

        if (event.data.exempt) {
            hud.className        = 'hud-visible hud-exempt';
            icon.textContent     = '⚡';
            status.textContent   = 'Exempt · Combat Allowed';
        } else {
            hud.className        = 'hud-visible hud-restricted';
            icon.textContent     = '🛡';
            status.textContent   = 'Combat Restricted';
        }
    }

    if (action === 'hideZoneHUD') {
        const hud = document.getElementById('zoneHUD');
        hud.className = 'hud-hidden';
    }
});

// ── Render zone list ─────────────────────────────────────────────────────────
function renderZones() {
    const list  = document.getElementById('zoneList');
    const badge = document.getElementById('zoneCount');
    badge.textContent = currentZones.length;
    list.innerHTML = '';

    if (currentZones.length === 0) {
        list.innerHTML = '<p class="empty-msg">No safe zones created yet.</p>';
        return;
    }

    currentZones.forEach(zone => {
        const div = document.createElement('div');
        div.className = 'zone-item';
        div.innerHTML = `
            <div class="zone-info">
                <strong>${escapeHtml(zone.name)}</strong>
                <span class="zone-meta">
                    📍 ${zone.center_x.toFixed(1)}, ${zone.center_y.toFixed(1)}, ${zone.center_z.toFixed(1)}
                    &nbsp;|&nbsp; ⭕ ${zone.radius}m &nbsp;|&nbsp; ↕ ${zone.height}m
                    &nbsp;|&nbsp; <span class="zone-id">ID: ${zone.id}</span>
                </span>
            </div>
            <button class="btn-delete" onclick="promptDelete(${zone.id}, '${escapeHtml(zone.name)}')">🗑 Delete</button>
        `;
        list.appendChild(div);
    });
}

// ── Add new zone ─────────────────────────────────────────────────────────────
function addNewZone() {
    const name   = document.getElementById('zoneName').value.trim();
    const cx     = parseFloat(document.getElementById('cx').value);
    const cy     = parseFloat(document.getElementById('cy').value);
    const cz     = parseFloat(document.getElementById('cz').value);
    const radius = parseFloat(document.getElementById('radius').value);
    const height = parseFloat(document.getElementById('height').value);

    if (!name)                        { flashInput('zoneName', 'Zone name is required'); return; }
    if (isNaN(cx)||isNaN(cy)||isNaN(cz)) { flashInput('cx', 'Use /addsafepoint or enter coords manually'); return; }
    if (isNaN(radius) || radius < 5)  { flashInput('radius', 'Minimum radius is 5m'); return; }
    if (isNaN(height) || height < 2)  { flashInput('height', 'Minimum height is 2m'); return; }

    fetch(`https://${GetParentResourceName()}/addZone`, {
        method: 'POST',
        body: JSON.stringify({ name, center_x: cx, center_y: cy, center_z: cz, radius, height })
    });

    document.getElementById('zoneName').value = '';
    document.getElementById('cx').value = '';
    document.getElementById('cy').value = '';
    document.getElementById('cz').value = '';
    document.getElementById('radius').value = '80';
    document.getElementById('height').value  = '20';
    const hint = document.getElementById('coordHint');
    hint.innerHTML = 'Stand at the desired location and use <strong>/addsafepoint</strong> to auto-fill coordinates.';
    hint.style.color = '';
}

// ── Delete with confirm modal ────────────────────────────────────────────────
function promptDelete(id, name) {
    pendingDeleteId   = id;
    pendingDeleteName = name;
    document.getElementById('confirmText').textContent = `Delete "${name}"? This cannot be undone.`;
    document.getElementById('confirmModal').classList.remove('hidden');
}

function cancelDelete() {
    pendingDeleteId   = null;
    pendingDeleteName = '';
    document.getElementById('confirmModal').classList.add('hidden');
}

function confirmDelete() {
    if (pendingDeleteId === null) return;
    fetch(`https://${GetParentResourceName()}/removeZone`, {
        method: 'POST',
        body: JSON.stringify({ id: pendingDeleteId })
    });
    document.getElementById('confirmModal').classList.add('hidden');
    pendingDeleteId   = null;
    pendingDeleteName = '';
}

// ── Close menu ───────────────────────────────────────────────────────────────
function closeMenu() {
    document.getElementById('container').classList.add('hidden');
    document.getElementById('confirmModal').classList.add('hidden');
    fetch(`https://${GetParentResourceName()}/closeMenu`, { method: 'POST' });
}

document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
        if (!document.getElementById('confirmModal').classList.contains('hidden')) {
            cancelDelete();
        } else {
            closeMenu();
        }
    }
});

// ── Helpers ──────────────────────────────────────────────────────────────────
function escapeHtml(str) {
    return String(str)
        .replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;')
        .replace(/"/g,'&quot;').replace(/'/g,'&#039;');
}

function flashInput(id, msg) {
    const el = document.getElementById(id);
    el.style.borderColor = '#ff4444';
    el.title = msg;
    el.focus();
    setTimeout(() => { el.style.borderColor = ''; el.title = ''; }, 2000);
}