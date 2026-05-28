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

function updateNav() {
    if (state.perfilActual) {
        document.getElementById('current-profile-display').textContent = state.perfilActual.nombre;
    }
    
    // Inyectar dinámicamente el botón de Reportes Admin solo si el ROL es ADMIN
    let adminBtn = document.getElementById('btn-admin-reports');
    if (state.user && state.user.rol === 'ADMIN') {
        if (!adminBtn) {
            adminBtn = document.createElement('button');
            adminBtn.id = 'btn-admin-reports';
            adminBtn.className = 'btn btn-warning';
            adminBtn.textContent = 'Módulo de Reportes';
            adminBtn.addEventListener('click', loadAdminReports);
            
            const nav = document.getElementById('main-nav');
            if(nav) {
                nav.insertBefore(adminBtn, document.getElementById('current-profile-display'));
            }
        }
    } else {
        // Si el usuario no es admin o cambia de estado, se destruye el botón por seguridad
        if (adminBtn) {
            adminBtn.remove();
        }
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
            let errorMsg = 'Error en la solicitud';
            if (isJson) {
                const errData = await response.json();
                errorMsg = errData.mensaje || errData.message || errorMsg; // GlobalExceptionHandler structure
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
    } catch (e) {
        // Error manejado en apiFetch
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

// ===== CATÁLOGO =====
async function loadCatalog() {
    switchView('dashboard-view');
    try {
        // Usar endpoint de catalogo publico o general (ajustar segun backend real)
        const data = await apiFetch('/api/contenidos?size=20');
        renderCatalog(data.content || []);
    } catch (e) {
        showToast('Error cargando el catálogo', 'error');
    }
}

function renderCatalog(contenidos) {
    const grid = document.getElementById('catalog-grid');
    grid.innerHTML = '';

    // Filtrar contenido infantil si el perfil es INFANTIL (simulacion frontend)
    const filtrados = state.perfilActual.tipo === 'INFANTIL' 
        ? contenidos.filter(c => c.categoria && c.categoria.nombreCategoria.toLowerCase().includes('infantil'))
        : contenidos;

    filtrados.forEach(c => {
        const div = document.createElement('div');
        div.className = 'content-card';
        div.innerHTML = `
            <img class="content-img" src="https://via.placeholder.com/300x169?text=${encodeURIComponent(c.titulo)}" alt="${c.titulo}">
            <div class="content-info">
                <div class="content-title">${c.titulo}</div>
                <div class="content-meta">${c.categoria ? c.categoria.nombreCategoria : 'Sin Categoría'}</div>
            </div>
        `;
        div.onclick = () => openContentModal(c);
        grid.appendChild(div);
    });
}

// ===== MODAL DE CONTENIDO Y SIMULACIÓN PL/SQL =====
const modal = document.getElementById('content-modal');
const closeModal = document.getElementById('close-modal');

function openContentModal(contenido) {
    state.contenidoActual = contenido.id;
    document.getElementById('modal-title').textContent = contenido.titulo;
    document.getElementById('modal-desc').textContent = contenido.descripcion || 'Sin descripción disponible.';
    
    // Reset inputs
    document.getElementById('rating-stars').value = '';
    document.getElementById('rating-review').value = '';
    
    modal.classList.remove('hidden');
}

closeModal.onclick = () => modal.classList.add('hidden');

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
        showToast('Reproducción guardada', 'success');
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
        showToast('Calificación enviada correctamente', 'success');
        modal.classList.add('hidden');
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
        
        data.forEach(r => {
            const tr = document.createElement('tr');
            tr.innerHTML = `
                <td>${r.titulo}</td>
                <td>${r.categoria}</td>
                <td>${r.totalReproducciones}</td>
                <td>${r.calificacionPromedio ? parseFloat(r.calificacionPromedio).toFixed(1) : 'N/A'}</td>
            `;
            tbody.appendChild(tr);
        });
        
        reportsModal.classList.remove('hidden');
    } catch (e) {
        showToast('Error cargando reportes', 'error');
    }
}

document.getElementById('close-reports-modal').onclick = () => reportsModal.classList.add('hidden');

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
