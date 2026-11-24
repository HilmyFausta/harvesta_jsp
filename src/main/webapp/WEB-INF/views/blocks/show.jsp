<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="h" uri="https://harvesta.app/functions" %>

<ui:layout title="Block ${block.name}" active="blocks">
    <ui:header title="${block.name}" description="Block details, planted trees, and yield summary.">
        <div class="flex items-center gap-2">
            <a href="${pageContext.request.contextPath}/blocks"
               class="inline-flex items-center text-sm font-medium text-zinc-600 hover:text-zinc-900 dark:text-zinc-300 dark:hover:text-white me-2">
                ← Back
            </a>
            <c:if test="${isAdmin}">
                <a href="${pageContext.request.contextPath}/blocks/${block.id}/edit"
                   class="inline-flex items-center gap-1.5 px-3 py-2 rounded-lg bg-[var(--color-accent)] text-white text-xs font-semibold hover:opacity-90">
                    ${h:icon('pencil')}
                    <span>Edit</span>
                </a>
            </c:if>
        </div>
    </ui:header>

    <!-- Block Info Card -->
    <div class="rounded-xl border border-zinc-200 bg-white p-6 shadow-xs dark:border-zinc-700 dark:bg-zinc-900 mb-8">
        <dl class="grid grid-cols-1 sm:grid-cols-3 gap-6 text-sm">
            <div>
                <dt class="text-xs font-semibold uppercase tracking-wider text-zinc-400">Total Area</dt>
                <dd class="mt-1 font-semibold text-zinc-900 dark:text-white text-base">${empty block.area_sqm ? '—' : h:number(block.area_sqm) += ' m²'}</dd>
            </div>
            <div>
                <dt class="text-xs font-semibold uppercase tracking-wider text-zinc-400">Location Note</dt>
                <dd class="mt-1 font-medium text-zinc-800 dark:text-zinc-200">${empty block.location_note ? '—' : h:e(block.location_note)}</dd>
            </div>
            <div>
                <dt class="text-xs font-semibold uppercase tracking-wider text-zinc-400">Total Harvests</dt>
                <dd class="mt-1 font-medium text-zinc-800 dark:text-zinc-200">${h:number(totalKg)} kg · ${h:number(totalPcs)} pcs</dd>
            </div>
            <c:if test="${not empty block.description}">
                <div class="sm:col-span-3">
                    <dt class="text-xs font-semibold uppercase tracking-wider text-zinc-400">Description</dt>
                    <dd class="mt-1 text-zinc-600 dark:text-zinc-300 whitespace-pre-line">${h:e(block.description)}</dd>
                </div>
            </c:if>
        </dl>
    </div>

    <!-- Trees in this Block -->
    <div class="rounded-xl border border-zinc-200 bg-white p-5 shadow-xs dark:border-zinc-700 dark:bg-zinc-900">
        <div class="flex items-center justify-between mb-4">
            <h2 class="text-base font-semibold text-zinc-800 dark:text-white">Planted Trees in this Block (${trees.size()})</h2>
            <c:if test="${canWrite}">
                <a href="${pageContext.request.contextPath}/trees/create?block_id=${block.id}" class="text-xs font-medium text-[var(--color-accent-content)] hover:underline">+ Add tree here</a>
            </c:if>
        </div>
        <c:choose>
            <c:when test="${not empty trees}">
                <div class="overflow-x-auto">
                    <table class="[:where(&)]:min-w-full table-fixed border-separate border-spacing-0 isolate text-zinc-800 dark:text-zinc-200 whitespace-nowrap" data-flux-table>
                        <thead>
                            <tr class="text-xs font-semibold uppercase tracking-wider text-zinc-500 border-b border-zinc-200 dark:border-zinc-700">
                                <th class="py-3 px-3 text-start">Tree</th>
                                <th class="py-3 px-3 text-start">Type</th>
                                <th class="py-3 px-3 text-start">Planted on</th>
                                <th class="py-3 px-3 text-start">Status</th>
                                <th class="py-3 px-3 text-end">Actions</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-zinc-100 dark:divide-zinc-800 text-sm">
                            <c:forEach var="t" items="${trees}">
                                <tr class="hover:bg-zinc-50 dark:hover:bg-zinc-800/50 transition-colors">
                                    <td class="py-3 px-3 font-semibold">
                                        <a href="${pageContext.request.contextPath}/trees/${t.id}" class="text-[var(--color-accent-content)] hover:underline">${h:e(t.code)}</a>
                                    </td>
                                    <td class="py-3 px-3 font-medium text-zinc-700 dark:text-zinc-300">${h:e(t.type_name)}</td>
                                    <td class="py-3 px-3 text-zinc-600 dark:text-zinc-400">${h:date(t.planted_on)}</td>
                                    <td class="py-3 px-3">${h:statusBadge(t.status)}</td>
                                    <td class="py-3 px-3 text-end">
                                        <a href="${pageContext.request.contextPath}/trees/${t.id}" class="p-1 text-zinc-500 hover:text-zinc-800 dark:hover:text-white" title="View details">
                                            ${h:icon('eye')}
                                        </a>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </c:when>
            <c:otherwise>
                <p class="text-sm text-zinc-500 py-4 text-center">No trees planted in this block yet.</p>
            </c:otherwise>
        </c:choose>
    </div>
</ui:layout>
