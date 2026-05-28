/* =====================================================
   QuindioFlix — Frontend Application Logic
   ===================================================== */

const $ = (id) => document.getElementById(id);

// ---- TOAST NOTIFICATIONS ----
function toast(message, type = "info", duration = 4000) {
  const container = $("toastContainer");
  const el = document.createElement("div");
  el.className = `toast ${type}`;
  el.textContent = message;
  container.appendChild(el);

  setTimeout(() => {
    el.classList.add("removing");
    setTimeout(() => el.remove(), 300);
  }, duration);
}

// ---- UTILITIES ----
function formatDate(d) {
  if (!d) return "";
  if (typeof d === "string") return d.slice(0, 10);
  return String(d);
}

function setLoading(el, loading = true) {
  if (loading) {
    el.innerHTML = '<span class="loading-pulse"></span> Cargando...';
  }
}

// ---- SELECT LOADERS ----
async function loadSelect(url, selectEl, idField, labelField) {
  try {
    const res = await fetch(url);
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    const data = await res.json();
    selectEl.innerHTML = "";
    data.forEach((item) => {
      const opt = document.createElement("option");
      opt.value = item[idField];
      opt.textContent = item[labelField];
      selectEl.appendChild(opt);
    });
  } catch (err) {
    console.error(`Error loading ${url}:`, err);
    selectEl.innerHTML = '<option value="">Error cargando datos</option>';
  }
}

// ---- CATALOG ----
function catalogCard(contenido, index) {
  const card = document.createElement("div");
  card.className = "card";
  card.style.animationDelay = `${index * 0.05}s`;

  const title = contenido.titulo ?? `(sin título #${contenido.id})`;
  const year = contenido.anoLanzamiento ?? contenido.ano_lanzamiento ?? "";
  const age = contenido.clasificacionEdad ?? "";
  const pop = contenido.popularidad ?? 0;
  const duration = contenido.duracionMinutos ? `${contenido.duracionMinutos} min` : "Serie";

  card.innerHTML = `
    <h3>${title}</h3>
    <div class="card-meta">
      <span>📅 ${year}</span>
      <span>🎯 ${age}</span>
      <span>⏱️ ${duration}</span>
    </div>
    <div class="popularity-bar">
      <div class="popularity-fill" style="width: ${Math.min(pop, 100)}%"></div>
    </div>
  `;

  card.addEventListener("click", () => openDetail(contenido.id));
  return card;
}

async function loadCatalog() {
  const page = $("page").value;
  const size = $("size").value;
  const sortBy = $("sortBy").value;
  const catalog = $("catalog");
  const meta = $("catalogMeta");

  catalog.innerHTML = "";
  setLoading(meta);

  try {
    const url = `/api/contenidos?page=${encodeURIComponent(page)}&size=${encodeURIComponent(size)}&sortBy=${encodeURIComponent(sortBy)}`;
    const res = await fetch(url);
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    const data = await res.json();
    const items = data.content ?? [];

    meta.textContent = `📦 ${data.totalElements ?? items.length} resultados · Página ${(data.number ?? page) + 1} de ${data.totalPages ?? 1}`;

    items.forEach((c, i) => catalog.appendChild(catalogCard(c, i)));

    if (items.length === 0) {
      meta.textContent = "No se encontró contenido en esta página.";
    }
  } catch (e) {
    console.error(e);
    meta.textContent = "";
    toast(`Error cargando catálogo: ${e.message}`, "error");
  }
}

async function openDetail(id) {
  const panel = $("detailPanel");
  panel.style.display = "block";
  const pre = $("detailJson");
  setLoading(pre);

  try {
    const res = await fetch(`/api/contenidos/${id}`);
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    const json = await res.json();
    pre.textContent = JSON.stringify(json, null, 2);
  } catch (e) {
    pre.textContent = `Error: ${e.message}`;
    toast(`Error cargando detalle: ${e.message}`, "error");
  }
}

// ---- REPORTS ----
async function loadReports() {
  const limit = Number($("topLimit").value || 10);
  const anio = $("repAnio").value ? Number($("repAnio").value) : null;
  const mes = $("repMes").value ? Number($("repMes").value) : null;

  const popTarget = $("repPopular");
  const ingTarget = $("repIngresos");
  setLoading(popTarget);
  setLoading(ingTarget);

  try {
    const popRes = await fetch(`/api/reportes/contenido-popular?limit=${encodeURIComponent(limit)}`);
    popTarget.textContent = popRes.ok
      ? JSON.stringify(await popRes.json(), null, 2)
      : `Error HTTP ${popRes.status}`;
  } catch (e) {
    popTarget.textContent = `Error: ${e.message}`;
  }

  try {
    const params = new URLSearchParams();
    if (anio) params.set("anio", String(anio));
    if (mes) params.set("mes", String(mes));
    const ingRes = await fetch(`/api/reportes/ingresos-mensuales${params.toString() ? `?${params}` : ""}`);
    ingTarget.textContent = ingRes.ok
      ? JSON.stringify(await ingRes.json(), null, 2)
      : `Error HTTP ${ingRes.status}`;
  } catch (e) {
    ingTarget.textContent = `Error: ${e.message}`;
  }
}

// ---- PAGE NAVIGATION ----
function switchPage(page) {
  document.querySelectorAll(".tab").forEach((btn) => {
    btn.classList.toggle("active", btn.dataset.page === page);
  });
  document.querySelectorAll("[data-section]").forEach((sec) => {
    sec.style.display = sec.dataset.section === page ? "block" : "none";
  });
}

// ---- WIRE UP ----
function wireUI() {
  // Tab navigation
  document.querySelectorAll(".tab").forEach((btn) => {
    btn.addEventListener("click", () => switchPage(btn.dataset.page));
  });

  // Load dropdowns for registration
  Promise.all([
    loadSelect("/api/public/ciudades", $("idCiudad"), "id", "nombreCiudad"),
    loadSelect("/api/public/planes", $("idPlan"), "id", "nombrePlan"),
  ]).catch(() => toast("Error cargando ciudades/planes desde la API.", "error"));

  // Catalog
  $("loadCatalogBtn").addEventListener("click", () => loadCatalog());
  $("closeDetailBtn").addEventListener("click", () => { $("detailPanel").style.display = "none"; });

  // User summary
  $("loadUserBtn").addEventListener("click", async () => {
    const id = Number($("usuarioId").value);
    const target = $("userSummary");
    const pagosTarget = $("userPagos");
    setLoading(target);
    setLoading(pagosTarget);

    try {
      const res = await fetch(`/api/usuarios/${id}/resumen`);
      if (!res.ok) throw new Error(`HTTP ${res.status}: usuario no encontrado`);
      target.textContent = JSON.stringify(await res.json(), null, 2);

      const pagosRes = await fetch(`/api/usuarios/${id}/pagos`);
      pagosTarget.textContent = pagosRes.ok
        ? JSON.stringify(await pagosRes.json(), null, 2)
        : "No se pudieron cargar los pagos.";
    } catch (err) {
      target.textContent = err.message;
      pagosTarget.textContent = "";
      toast(err.message, "error");
    }
  });

  // Change plan
  $("changePlanBtn").addEventListener("click", async () => {
    const id = Number($("usuarioId").value);
    const nuevoPlanId = Number($("nuevoPlanId").value);
    if (!id || !nuevoPlanId) {
      toast("Ingresa ID de usuario y nuevo plan.", "warning");
      return;
    }
    try {
      const res = await fetch(`/api/usuarios/${id}/cambiar-plan?nuevoPlanId=${encodeURIComponent(nuevoPlanId)}`, { method: "POST" });
      if (!res.ok) throw new Error(`Error HTTP ${res.status}`);
      toast("✅ Plan cambiado exitosamente (SP_CAMBIAR_PLAN). Recarga el usuario.", "success");
    } catch (e) {
      toast(e.message, "error");
    }
  });

  // Registration form
  $("registerForm").addEventListener("submit", async (e) => {
    e.preventDefault();
    const msg = $("registerMsg");

    const payload = {
      nombreCompleto: $("nombreCompleto").value,
      email: $("email").value,
      contrasena: $("contrasena").value,
      telefono: $("telefono").value || null,
      fechaNacimiento: $("fechaNacimiento").value,
      idCiudad: Number($("idCiudad").value),
      idPlan: Number($("idPlan").value),
    };

    try {
      const res = await fetch("/api/auth/register", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload),
      });
      if (!res.ok) {
        const errText = await res.text();
        throw new Error(errText || `HTTP ${res.status}`);
      }
      const data = await res.json();
      
      if (data && data.id) {
        $("usuarioId").value = data.id;
        msg.innerHTML = `✅ Registro exitoso. Tu ID asignado es <strong>${data.id}</strong> (se ha configurado automáticamente en la pestaña 'Usuarios').`;
      } else {
        msg.textContent = "✅ Registro exitoso. Ya puedes navegar el catálogo.";
      }
      
      msg.className = "message success";
      toast("🎉 Usuario registrado exitosamente!", "success");
      e.target.reset();
    } catch (err) {
      msg.textContent = `❌ ${err.message}`;
      msg.className = "message error";
      toast(`Error al registrar: ${err.message}`, "error");
    }
  });

  // Reports
  $("loadReportsBtn").addEventListener("click", () => loadReports());

  // Initial load
  switchPage("catalogo");
  loadCatalog();

  toast("🎬 QuindioFlix cargado correctamente!", "success", 3000);
}

document.addEventListener("DOMContentLoaded", wireUI);
