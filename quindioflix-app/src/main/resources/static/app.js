// ===== ESTADO GLOBAL =====
const state = {
    user: null, // { token, idUsuario, nombre, email, rol }
    perfiles: [],
    perfilActual: null, // { id, nombre, tipo }
    contenidoActual: null // ID del contenido seleccionado en el modal
};

// ===== UI HELPERS (TOASTS & VIEWS) =====
function showToast(message, type = 'error') {
    const container = document.getElementById('toast-container');
    const toast = document.createElement('div');
    toast.className = `toast ${type}`;
    toast.textContent = message;
    container.appendChild(toast);
    
    // Auto-remove
    setTimeout(() => {
        if(container.contains(toast)) container.removeChild(toast);
    }, 4000);
}

function switchView(viewId) {
    document.querySelectorAll('.view').forEach(v => v.classList.replace('active', 'hidden'));
    document.getElementById(viewId).classList.replace('hidden', 'active');
}

function openModal(modalEl) {
    modalEl.classList.remove('hidden');
    document.body.classList.add('modal-open');
}

function closeModal(modalEl) {
    modalEl.classList.add('hidden');
    if (!document.querySelector('.modal:not(.hidden)')) {
        document.body.classList.remove('modal-open');
    }
}

function updateNav() {
    if (state.perfilActual) {
        document.getElementById('current-profile-display').textContent = state.perfilActual.nombre;
    }

    const planBtn = document.getElementById('btn-change-plan');
    if (planBtn) {
        planBtn.style.display = (state.user && state.user.rol === 'ADMIN') ? 'none' : 'inline-block';
    }

    const nav = document.getElementById('main-nav');
    const anchor = document.getElementById('current-profile-display');

    ['btn-admin-reports', 'btn-admin-clients'].forEach(id => {
        const el = document.getElementById(id);
        if (el) el.remove();
    });

    if (state.user && state.user.rol === 'ADMIN' && nav) {
        const clientsBtn = document.createElement('button');
        clientsBtn.id = 'btn-admin-clients';
        clientsBtn.className = 'btn btn-warning';
        clientsBtn.textContent = 'Ver Clientes';
        clientsBtn.addEventListener('click', loadAdminClients);
        nav.insertBefore(clientsBtn, anchor);

        const reportsBtn = document.createElement('button');
        reportsBtn.id = 'btn-admin-reports';
        reportsBtn.className = 'btn btn-warning';
        reportsBtn.textContent = 'Reportes';
        reportsBtn.addEventListener('click', loadAdminReports);
        nav.insertBefore(reportsBtn, anchor);
    }
}

// ===== API FETCH WRAPPER =====
async function apiFetch(endpoint, options = {}) {
    const headers = { 'Content-Type': 'application/json' };
    
    // Add Authorization header if logged in
    const token = sessionStorage.getItem('qf_token');
    if (token) {
        headers['Authorization'] = `Bearer ${token}`;
    }

    const config = { ...options, headers: { ...headers, ...options.headers } };

    try {
        const response = await fetch(endpoint, config);
        const isJson = response.headers.get('content-type')?.includes('application/json');
        
        if (!response.ok) {
            // Manejo de caducidad de sesion o no autorizado
            if (response.status === 401 || response.status === 403) {
                sessionStorage.clear();
                showToast("Tu sesión ha caducado. Inicia sesión nuevamente.", "error");
                switchView('login-view');
                throw new Error("Sesión caducada");
            }

            let errorMsg = 'Error en la solicitud';
            if (isJson) {
                const errData = await response.json();
                errorMsg = errData.mensaje || errData.message || errData.error || errorMsg; // GlobalExceptionHandler structure
            } else {
                errorMsg = await response.text() || errorMsg;
            }
            showToast(errorMsg, 'error');
            throw new Error(errorMsg);
        }
        
        return isJson ? await response.json() : null;
    } catch (error) {
        // Ignorar si el error ya fue manejado por no ser ok
        if (!error.message.includes('Error en la solicitud')) {
           // showToast("Error de conexión con el servidor", 'error'); // Optional
        }
        throw error;
    }
}

// ===== LOGIN =====
document.getElementById('login-form').addEventListener('submit', async (e) => {
    e.preventDefault();
    const email = document.getElementById('email').value;
    const password = document.getElementById('password').value;
    const btnSubmit = document.querySelector('#login-form button[type="submit"]');

    btnSubmit.disabled = true;
    const originalText = btnSubmit.textContent;
    btnSubmit.textContent = "Cargando...";

    try {
        const data = await apiFetch('/api/auth/login', {
            method: 'POST',
            body: JSON.stringify({ email, password })
        });

        // Guardar sesión
        state.user = data;
        sessionStorage.setItem('qf_user', JSON.stringify(data));
        sessionStorage.setItem('qf_token', data.token);

        showToast(`Bienvenido, ${data.nombre}`, 'success');
        loadProfiles();
    } catch (err) {
        showToast(err.message || 'Error al iniciar sesión', 'error');
    } finally {
        btnSubmit.disabled = false;
        btnSubmit.textContent = originalText;
    }
});

document.getElementById('btn-logout').addEventListener('click', () => {
    sessionStorage.clear();
    state.user = null;
    state.perfilActual = null;
    switchView('login-view');
});

// ===== PERFILES =====
async function loadProfiles() {
    switchView('profile-selection-view');
    try {
        const data = await apiFetch(`/api/usuarios/${state.user.idUsuario}/resumen`);
        state.perfiles = data.perfiles || [];
        renderProfiles();
        updateNav();
    } catch (e) {
        showToast('No se pudieron cargar los perfiles', 'error');
    }
}

function renderProfiles() {
    const grid = document.getElementById('profiles-grid');
    grid.innerHTML = '';

    state.perfiles.forEach(p => {
        const div = document.createElement('div');
        div.className = `profile-card ${p.tipo === 'INFANTIL' ? 'infantil' : ''}`;
        div.innerHTML = `
            <div class="profile-avatar"></div>
            <div class="profile-name">${p.nombre}</div>
        `;
        div.onclick = () => selectProfile(p);
        grid.appendChild(div);
    });
}

function selectProfile(perfil) {
    state.perfilActual = perfil;
    updateNav();
    loadCatalog();
}

document.getElementById('btn-switch-profile').addEventListener('click', () => {
    loadProfiles();
});

// Portadas fijas por id (respaldo si el backend no envia urlPortada)
const PORTADAS_QUEMADAS = {
    1: 'https://picsum.photos/seed/qf-guardian/300/169',
    2: 'https://picsum.photos/seed/qf-digital/300/169',
    3: 'https://picsum.photos/seed/qf-cafe/300/169',
    4: 'https://picsum.photos/seed/qf-tango/300/169',
    5: 'https://picsum.photos/seed/qf-bio/300/169',
    6: 'https://picsum.photos/seed/qf-rojo/300/169',
    7: 'https://picsum.photos/seed/qf-herencia/300/169',
    8: 'https://picsum.photos/seed/qf-vuelo/300/169',
    9: 'https://picsum.photos/seed/qf-cocora/300/169',
    10: 'https://picsum.photos/seed/qf-voces/300/169',
    11: 'https://picsum.photos/seed/qf-sombras/300/169',
    12: 'https://picsum.photos/seed/qf-startup/300/169'
};

function portadaDe(contenido) {
    return contenido.urlPortada || PORTADAS_QUEMADAS[contenido.id] || `https://picsum.photos/seed/qf-${contenido.id}/300/169`;
}

function esAptoParaInfantil(contenido) {
    const edad = (contenido.clasificacionEdad || '').toUpperCase().trim();
    if (edad === 'TP' || edad === 'TODOS' || edad === '+7') return true;
    const cat = (contenido.nombreCategoria || '').toLowerCase();
    return cat.includes('animacion') || cat.includes('documental');
}

function filtrarPorPerfil(contenidos) {
    if (!state.perfilActual) return contenidos;
    if (state.perfilActual.tipo === 'INFANTIL') {
        return contenidos.filter(esAptoParaInfantil);
    }
    return contenidos;
}

// ===== CATÁLOGO =====
let catalogData = [];

async function loadCatalog() {
    switchView('dashboard-view');
    try {
        const data = await apiFetch('/api/contenidos?size=40');
        catalogData = data.content || [];
        applyFilters();
    } catch (e) {
        showToast('Error cargando el catálogo', 'error');
    }
}

function applyFilters() {
    let filtrados = filtrarPorPerfil(catalogData);
    
    const searchVal = (document.getElementById('search-filter')?.value || '').toLowerCase();
    const catVal = document.getElementById('category-filter')?.value || '';
    
    if (searchVal) {
        filtrados = filtrados.filter(c => c.titulo.toLowerCase().includes(searchVal));
    }
    
    if (catVal) {
        filtrados = filtrados.filter(c => c.nombreCategoria && c.nombreCategoria.includes(catVal));
    }
    
    if (filtrados.length === 0 && (searchVal || catVal)) {
        document.getElementById('catalog-grid').innerHTML = '<p style="grid-column: 1 / -1; text-align: center; color: #aaa;">No se encontraron resultados para tu búsqueda.</p>';
        return;
    } else if (filtrados.length === 0) {
        showToast('No hay títulos para este perfil', 'error');
    }
    renderCatalog(filtrados);
}

document.getElementById('search-filter')?.addEventListener('input', applyFilters);
document.getElementById('category-filter')?.addEventListener('change', applyFilters);

function renderCatalog(contenidos) {
    const grid = document.getElementById('catalog-grid');
    grid.innerHTML = '';

    contenidos.forEach(c => {
        const div = document.createElement('div');
        div.className = 'content-card';
        const imgSrc = portadaDe(c);
        div.innerHTML = `
            <img class="content-img" src="${imgSrc}" alt="${c.titulo}" loading="lazy"
                 onerror="this.onerror=null;this.src='https://picsum.photos/seed/fallback-${c.id}/300/169'">
            <div class="content-info">
                <div class="content-title">${c.titulo}</div>
                <div class="content-meta">${c.nombreCategoria || 'Sin categoría'} · ${c.clasificacionEdad || ''}</div>
            </div>
        `;
        div.onclick = () => openContentModal(c);
        grid.appendChild(div);
    });
}

// ===== MODAL DE CONTENIDO Y SIMULACIÓN PL/SQL =====
const modal = document.getElementById('content-modal');
const closeContentModalBtn = document.getElementById('close-modal');

async function openContentModal(contenido) {
    state.contenidoActual = contenido.id;
    document.getElementById('modal-title').textContent = contenido.titulo;
    document.getElementById('modal-poster').src = portadaDe(contenido);
    document.getElementById('modal-badges').innerHTML = '';
    document.getElementById('modal-meta').innerHTML = '<p class="detail-loading">Cargando ficha del título...</p>';
    document.getElementById('modal-series').classList.add('hidden');
    document.getElementById('modal-desc').textContent = '';
    document.getElementById('rating-stars').value = '';
    document.getElementById('rating-review').value = '';
    openModal(modal);

    try {
        const det = await apiFetch(`/api/contenidos/${contenido.id}`);
        renderContentDetail(det);
    } catch (e) {
        document.getElementById('modal-desc').textContent = contenido.sinopsis || 'Sin descripción disponible.';
        document.getElementById('modal-meta').innerHTML =
            `<div class="meta-item"><span class="meta-label">Categoría</span><span>${contenido.nombreCategoria || '—'}</span></div>`;
    }
}

function renderContentDetail(det) {
    document.getElementById('modal-title').textContent = det.titulo;
    document.getElementById('modal-poster').src = det.urlPortada || portadaDe(det);
    document.getElementById('modal-desc').textContent = det.sinopsis || 'Sinopsis no disponible.';

    const badges = document.getElementById('modal-badges');
    badges.innerHTML = `
        <span class="badge badge-cat">${det.nombreCategoria}</span>
        <span class="badge badge-age">${det.clasificacionEdad}</span>
        ${det.esOriginal ? '<span class="badge badge-original">Original QuindioFlix</span>' : ''}
        <span class="badge badge-state">${det.estado || 'ACTIVO'}</span>
    `;

    const generosTexto = det.generos && det.generos.length
        ? det.generos.join(', ')
        : 'No especificados';

    document.getElementById('modal-meta').innerHTML = `
        <div class="meta-grid">
            <div class="meta-item"><span class="meta-label">Categoría</span><span>${det.nombreCategoria}</span></div>
            <div class="meta-item"><span class="meta-label">Tipo</span><span>${det.esSerie ? 'Serie / Serial' : 'Película'}</span></div>
            <div class="meta-item"><span class="meta-label">Año</span><span>${det.anoLanzamiento || '—'}</span></div>
            <div class="meta-item"><span class="meta-label">Duración</span><span>${det.duracionTexto}</span></div>
            <div class="meta-item"><span class="meta-label">Géneros</span><span>${generosTexto}</span></div>
            <div class="meta-item"><span class="meta-label">Popularidad</span><span>${det.popularidad ?? '—'} / 100</span></div>
        </div>
    `;

    const seriesBlock = document.getElementById('modal-series');
    if (det.esSerie) {
        let seriesHtml = `
            <h3>Información de la serie</h3>
            <p class="series-summary">
                <strong>${det.totalTemporadas}</strong> temporada(s) ·
                <strong>${det.totalEpisodios}</strong> episodio(s) en total
            </p>
        `;
        if (det.temporadas && det.temporadas.length > 0) {
            seriesHtml += '<ul class="season-list">';
            det.temporadas.forEach(t => {
                seriesHtml += `<li>Temporada ${t.numeroTemporada}: ${t.cantidadEpisodios} episodio(s)</li>`;
            });
            seriesHtml += '</ul>';
        } else {
            seriesHtml += '<p class="series-note">Este título pertenece al catálogo serial; los capítulos se irán publicando próximamente.</p>';
        }
        seriesBlock.innerHTML = seriesHtml;
        seriesBlock.classList.remove('hidden');
    } else {
        seriesBlock.classList.add('hidden');
    }
}

closeContentModalBtn.onclick = () => closeModal(modal);

// Simular Reproducción
document.getElementById('btn-play').addEventListener('click', async () => {
    if (!state.perfilActual || !state.contenidoActual) return;
    
    try {
        await apiFetch('/api/contenidos/reproducir', {
            method: 'POST',
            body: JSON.stringify({
                idPerfil: state.perfilActual.id,
                idContenido: state.contenidoActual,
                dispositivo: 'WEB',
                porcentajeAvance: Math.floor(Math.random() * 100) // Simular un avance aleatorio entre 0 y 100
            })
        });
        showToast('Reproducción guardada en la base de datos', 'success');
    } catch (e) {
        // Error es manejado en apiFetch
    }
});

// Simular Calificación (Provocará error de PL/SQL Trigger si porcentaje < 50%)
document.getElementById('btn-rate').addEventListener('click', async () => {
    if (!state.perfilActual || !state.contenidoActual) return;
    
    const estrellas = document.getElementById('rating-stars').value;
    const resena = document.getElementById('rating-review').value;

    if (!estrellas || estrellas < 1 || estrellas > 5) {
        showToast('Ingresa una calificación válida (1-5)', 'error');
        return;
    }

    try {
        await apiFetch('/api/contenidos/calificar', {
            method: 'POST',
            body: JSON.stringify({
                idPerfil: state.perfilActual.id,
                idContenido: state.contenidoActual,
                estrellas: parseInt(estrellas),
                resena: resena
            })
        });
        showToast('Calificación guardada correctamente', 'success');
        closeModal(modal);
    } catch (e) {
        // Si el trigger rechaza, se mostrará el toast de error gracias a apiFetch!
    }
});

// ===== REPORTES (ADMIN) =====
const reportsModal = document.getElementById('reports-modal');

async function loadAdminReports() {
    try {
        const data = await apiFetch('/api/reportes/populares');
        const tbody = document.getElementById('reports-body');
        tbody.innerHTML = '';
        
        if (!data || data.length === 0) {
            tbody.innerHTML = '<tr><td colspan="4">Sin datos en el reporte</td></tr>';
        } else {
            data.forEach(r => {
                const tr = document.createElement('tr');
                tr.innerHTML = `
                    <td>${r.titulo}</td>
                    <td>${r.categoria}</td>
                    <td>${r.totalReproducciones ?? 0}</td>
                    <td>${r.calificacionPromedio != null ? parseFloat(r.calificacionPromedio).toFixed(1) : 'N/A'}</td>
                `;
                tbody.appendChild(tr);
            });
        }
        
        openModal(reportsModal);
    } catch (e) {
        showToast('Error cargando reportes', 'error');
    }
}

document.getElementById('close-reports-modal').onclick = () => closeModal(reportsModal);

// ===== CAMBIAR PLAN =====
const planModal = document.getElementById('plan-modal');
const planStepSelect = document.getElementById('plan-step-select');
const planStepCheckout = document.getElementById('plan-step-checkout');
const checkoutForm = document.getElementById('checkout-form');
const checkoutProcessing = document.getElementById('checkout-processing');
const checkoutSuccess = document.getElementById('checkout-success');
let planesDisponibles = [];
let planSeleccionado = null;

document.getElementById('btn-change-plan').addEventListener('click', openPlanModal);
document.getElementById('close-plan-modal').onclick = () => cerrarPlanModal();
document.getElementById('btn-checkout-back').onclick = () => mostrarPasoPlan('select');
document.getElementById('btn-checkout-done').onclick = () => cerrarPlanModal();
checkoutForm.addEventListener('submit', procesarPagoPlan);

function cerrarPlanModal() {
    closeModal(planModal);
    resetCheckoutUi();
    mostrarPasoPlan('select');
}

function resetCheckoutUi() {
    checkoutForm.classList.remove('hidden');
    checkoutProcessing.classList.add('hidden');
    checkoutSuccess.classList.add('hidden');
    planSeleccionado = null;
}

function mostrarPasoPlan(paso) {
    if (paso === 'select') {
        planStepSelect.classList.remove('hidden');
        planStepCheckout.classList.add('hidden');
        resetCheckoutUi();
    } else {
        planStepSelect.classList.add('hidden');
        planStepCheckout.classList.remove('hidden');
    }
}

async function openPlanModal() {
    try {
        const [planes, resumen] = await Promise.all([
            apiFetch('/api/public/planes'),
            apiFetch(`/api/usuarios/${state.user.idUsuario}/resumen`)
        ]);
        planesDisponibles = planes;
        document.getElementById('plan-current-label').textContent =
            `Plan actual: ${resumen.plan || '—'}`;

        const grid = document.getElementById('plans-options');
        grid.innerHTML = '';
        planes.forEach(pl => {
            const card = document.createElement('div');
            card.className = 'plan-card';
            card.innerHTML = `
                <h3>${pl.nombrePlan}</h3>
                <p>${pl.calidad} · ${pl.limitePantallas} pantalla(s)</p>
                <p>Hasta ${pl.maxPerfiles} perfiles</p>
                <p class="plan-price">$${pl.precioMensual.toLocaleString('es-CO')}/mes</p>
                <button class="btn btn-primary btn-select-plan" data-plan-id="${pl.id}">Elegir</button>
            `;
            if (resumen.idPlan === pl.id) {
                card.classList.add('plan-active');
            }
            grid.appendChild(card);
        });

        grid.querySelectorAll('.btn-select-plan').forEach(btn => {
            btn.addEventListener('click', () => {
                const planId = parseInt(btn.dataset.planId, 10);
                const plan = planesDisponibles.find(p => p.id === planId);
                if (resumen.idPlan === planId) {
                    showToast('Ya tienes este plan activo', 'error');
                    return;
                }
                iniciarCheckout(plan);
            });
        });

        mostrarPasoPlan('select');
        openModal(planModal);
    } catch (e) {
        showToast('No se pudieron cargar los planes', 'error');
    }
}

function iniciarCheckout(plan) {
    planSeleccionado = plan;
    document.getElementById('checkout-summary').textContent =
        `Vas a pagar $${plan.precioMensual.toLocaleString('es-CO')} por el plan ${plan.nombrePlan}`;
    const nombreInput = document.getElementById('pay-name');
    if (state.user && !nombreInput.value) {
        nombreInput.value = state.user.nombre || '';
    }
    mostrarPasoPlan('checkout');
}

async function procesarPagoPlan(e) {
    e.preventDefault();
    if (!state.user || !planSeleccionado) return;

    checkoutForm.classList.add('hidden');
    checkoutProcessing.classList.remove('hidden');

    const payload = {
        nuevoPlanId: planSeleccionado.id,
        numeroTarjeta: document.getElementById('pay-card').value,
        nombreTitular: document.getElementById('pay-name').value,
        metodoPago: document.getElementById('pay-method').value
    };

    await new Promise(r => setTimeout(r, 1800));

    try {
        const result = await apiFetch(`/api/usuarios/${state.user.idUsuario}/cambiar-plan-pago`, {
            method: 'POST',
            body: JSON.stringify(payload)
        });

        checkoutProcessing.classList.add('hidden');
        checkoutSuccess.classList.remove('hidden');
        document.getElementById('checkout-success-title').textContent = '¡Pago aprobado!';
        document.getElementById('checkout-success-detail').innerHTML =
            `${result.mensaje}<br><br>` +
            `<strong>Referencia:</strong> ${result.referenciaTransaccion}<br>` +
            `<strong>Monto:</strong> $${result.monto.toLocaleString('es-CO')}<br>` +
            `<strong>Plan:</strong> ${result.planAnterior} → ${result.planNuevo}`;

        const resumen = await apiFetch(`/api/usuarios/${state.user.idUsuario}/resumen`);
        if (state.user) state.user.plan = resumen.plan;
        showToast('Suscripción actualizada', 'success');
    } catch (err) {
        checkoutProcessing.classList.add('hidden');
        checkoutForm.classList.remove('hidden');
    }
}

// ===== CLIENTES ADMIN =====
const clientsModal = document.getElementById('clients-modal');

async function loadAdminClients() {
    try {
        const data = await apiFetch('/api/admin/clientes');
        const tbody = document.getElementById('clients-body');
        tbody.innerHTML = '';
        data.forEach(c => {
            const tr = document.createElement('tr');
            tr.innerHTML = `
                <td>${c.nombreCompleto}</td>
                <td>${c.email}</td>
                <td>${c.ciudad}</td>
                <td><strong>${c.plan}</strong></td>
                <td>${c.estadoCuenta}</td>
                <td>${c.cantidadPerfiles}</td>
            `;
            tbody.appendChild(tr);
        });
        openModal(clientsModal);
    } catch (e) {
        showToast('Error cargando clientes', 'error');
    }
}

document.getElementById('close-clients-modal').onclick = () => closeModal(clientsModal);

// ===== INIT =====
window.onload = () => {
    // Validar en carga de pagina si ya existe sesion persistente para saltarse el Login
    const savedUser = sessionStorage.getItem('qf_user');
    const savedToken = sessionStorage.getItem('qf_token');
    
    if (savedUser && savedToken) {
        state.user = JSON.parse(savedUser);
        // Redirigir/renderizar directamente la vista de "Selección de Perfil"
        loadProfiles();
    } else {
        // Asegurar que el login se muestre si no hay sesion
        switchView('login-view');
    }
};
