const $ = (id) => document.getElementById(id);

function formatDate(d) {
  if (!d) return "";
  // Si el backend devuelve string ISO, lo intentamos adaptar.
  if (typeof d === "string") {
    // YYYY-MM-DD o YYYY-MM-DDTHH:mm:ss
    return d.slice(0, 10);
  }
  return String(d);
}

async function loadSelect(url, selectEl, idField, labelField) {
  const res = await fetch(url);
  if (!res.ok) throw new Error(`HTTP ${res.status} al cargar ${url}`);
  const data = await res.json();

  selectEl.innerHTML = "";
  data.forEach((item) => {
    const opt = document.createElement("option");
    opt.value = item[idField];
    opt.textContent = item[labelField];
    selectEl.appendChild(opt);
  });
}

function showMessage(el, msg, isError = false) {
  el.textContent = msg;
  el.style.borderColor = isError ? "rgba(239,68,68,.35)" : "rgba(96,165,250,.35)";
}

function catalogCard(contenido) {
  const h = document.createElement("h3");
  h.textContent = contenido.titulo ?? `(sin titulo #${contenido.id})`;

  const p = document.createElement("div");
  p.className = "muted";

  const anio = contenido.anoLanzamiento ?? contenido.ano_lanzamiento ?? "";
  const edad = contenido.clasificacionEdad ?? "";
  const pop = contenido.popularidad ?? "";

  p.textContent = `Año: ${anio} | Edad: ${edad} | Popularidad: ${pop}`;

  const card = document.createElement("div");
  card.className = "card";
  card.appendChild(h);
  card.appendChild(p);
  card.addEventListener("click", () => openDetail(contenido.id));
  return card;
}

async function loadCatalog() {
  const page = $("page").value;
  const size = $("size").value;
  const sortBy = $("sortBy").value;

  const catalog = $("catalog");
  catalog.innerHTML = "";
  $("catalogMeta").textContent = "Cargando...";

  const url = `/api/contenidos?page=${encodeURIComponent(page)}&size=${encodeURIComponent(size)}&sortBy=${encodeURIComponent(sortBy)}`;
  const res = await fetch(url);
  if (!res.ok) throw new Error(`HTTP ${res.status} al cargar catálogo`);

  const data = await res.json();
  const items = data.content ?? [];

  $("catalogMeta").textContent = `Resultados: ${data.totalElements ?? items.length} | Página: ${data.number ?? page}`;

  items.forEach((c) => catalog.appendChild(catalogCard(c)));
}

async function openDetail(id) {
  const panel = $("detailPanel");
  panel.style.display = "block";

  const pre = $("detailJson");
  pre.textContent = "Cargando detalle...";

  const res = await fetch(`/api/contenidos/${id}`);
  if (!res.ok) throw new Error(`HTTP ${res.status} al cargar detalle`);
  const json = await res.json();

  pre.textContent = JSON.stringify(json, null, 2);
}

async function loadReports() {
  const limit = Number($("topLimit").value || 10);
  const anio = $("repAnio").value ? Number($("repAnio").value) : null;
  const mes = $("repMes").value ? Number($("repMes").value) : null;

  const popularTarget = $("repPopular");
  const ingresosTarget = $("repIngresos");
  popularTarget.textContent = "Cargando...";
  ingresosTarget.textContent = "Cargando...";

  const popRes = await fetch(`/api/reportes/contenido-popular?limit=${encodeURIComponent(limit)}`);
  if (popRes.ok) {
    const pop = await popRes.json();
    popularTarget.textContent = JSON.stringify(pop, null, 2);
  } else {
    popularTarget.textContent = `Error HTTP ${popRes.status}`;
  }

  const params = new URLSearchParams();
  if (anio) params.set("anio", String(anio));
  if (mes) params.set("mes", String(mes));

  const ingRes = await fetch(`/api/reportes/ingresos-mensuales${params.toString() ? `?${params}` : ""}`);
  if (ingRes.ok) {
    const ing = await ingRes.json();
    ingresosTarget.textContent = JSON.stringify(ing, null, 2);
  } else {
    ingresosTarget.textContent = `Error HTTP ${ingRes.status}`;
  }
}

function switchPage(page) {
  document.querySelectorAll(".tab").forEach((btn) => {
    btn.classList.toggle("active", btn.dataset.page === page);
  });
  document.querySelectorAll("[data-section]").forEach((sec) => {
    sec.style.display = sec.dataset.section === page ? "block" : "none";
  });
}

function wireUI() {
  // Navegación entre pestañas
  document.querySelectorAll(".tab").forEach((btn) => {
    btn.addEventListener("click", () => switchPage(btn.dataset.page));
  });

  // Cargar combos (planes/ciudades) para que el registro sea usable.
  Promise.all([
    loadSelect("/api/public/ciudades", $("idCiudad"), "id", "nombreCiudad"),
    loadSelect("/api/public/planes", $("idPlan"), "id", "nombrePlan"),
  ]).catch((err) => {
    console.error(err);
    showMessage($("registerMsg"), "Error cargando ciudades/planes. Revisa la API.", true);
  });

  $("loadCatalogBtn").addEventListener("click", () => {
    loadCatalog().catch((e) => showMessage($("registerMsg"), e.message, true));
  });

  $("closeDetailBtn").addEventListener("click", () => {
    $("detailPanel").style.display = "none";
  });

  $("loadUserBtn").addEventListener("click", async () => {
    const id = Number($("usuarioId").value);
    const target = $("userSummary");
    const pagosTarget = $("userPagos");
    target.textContent = "Cargando usuario...";
    pagosTarget.textContent = "Cargando pagos...";
    try {
      const res = await fetch(`/api/usuarios/${id}/resumen`);
      if (!res.ok) {
        const text = await res.text();
        throw new Error(`HTTP ${res.status}: ${text || "usuario no encontrado"}`);
      }
      const data = await res.json();
      target.textContent = JSON.stringify(data, null, 2);

      const pagosRes = await fetch(`/api/usuarios/${id}/pagos`);
      if (pagosRes.ok) {
        const pagos = await pagosRes.json();
        pagosTarget.textContent = JSON.stringify(pagos, null, 2);
      } else {
        pagosTarget.textContent = "No se pudieron cargar los pagos.";
      }
    } catch (err) {
      console.error(err);
      target.textContent = err.message;
      $("userPagos").textContent = "";
    }
  });

  $("changePlanBtn").addEventListener("click", async () => {
    const id = Number($("usuarioId").value);
    const nuevoPlanId = Number($("nuevoPlanId").value);
    if (!id || !nuevoPlanId) {
      alert("Ingresa ID de usuario y nuevo plan.");
      return;
    }
    try {
      const res = await fetch(`/api/usuarios/${id}/cambiar-plan?nuevoPlanId=${encodeURIComponent(nuevoPlanId)}`, {
        method: "POST",
      });
      if (!res.ok) {
        const t = await res.text();
        throw new Error(`Error al cambiar plan: HTTP ${res.status} - ${t || "sin detalle"}`);
      }
      alert("Plan cambiado (SP_CAMBIAR_PLAN ejecutado). Vuelve a cargar el usuario para ver cambios.");
    } catch (e) {
      console.error(e);
      alert(e.message);
    }
  });

  $("registerForm").addEventListener("submit", async (e) => {
    e.preventDefault();
    const msg = $("registerMsg");
    msg.textContent = "";

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
        throw new Error(`Error al registrar (HTTP ${res.status}): ${errText || "sin detalle"}`);
      }

      showMessage(msg, "Registro exitoso. Ya puedes navegar el catálogo.");
      e.target.reset();
    } catch (err) {
      console.error(err);
      showMessage(msg, err.message, true);
    }
  });

  $("loadReportsBtn").addEventListener("click", () => {
    loadReports().catch((e) => {
      console.error(e);
      $("repPopular").textContent = e.message;
      $("repIngresos").textContent = e.message;
    });
  });

  // Pantalla inicial: catálogo
  switchPage("catalogo");
  loadCatalog().catch((e) => {
    console.error(e);
    $("catalogMeta").textContent = "";
    showMessage($("registerMsg"), e.message, true);
  });
}

document.addEventListener("DOMContentLoaded", wireUI);

