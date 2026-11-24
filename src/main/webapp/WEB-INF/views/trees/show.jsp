<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="h" uri="https://harvesta.app/functions" %>

<ui:layout title="Tree ${tree.code}" active="trees">
    <ui:header title="Tree ${tree.code}" description="${tree.type_name} in ${tree.block_name}">
        <div class="flex items-center gap-2">
            <a href="${pageContext.request.contextPath}/trees"
               class="inline-flex items-center text-sm font-medium text-zinc-600 hover:text-zinc-900 dark:text-zinc-300 dark:hover:text-white me-2">
                ← Back
            </a>
            <c:if test="${tree.status != 'dead' && canWrite}">
                <a href="${pageContext.request.contextPath}/care-logs/create?tree_id=${tree.id}"
                   class="inline-flex items-center gap-1.5 px-3 py-2 rounded-lg border border-zinc-200 dark:border-zinc-700 bg-white dark:bg-zinc-800 text-xs font-semibold text-zinc-700 dark:text-zinc-200 hover:bg-zinc-50 dark:hover:bg-zinc-700">
                    ${h:icon('care-logs')}
                    <span>Add care log</span>
                </a>
                <a href="${pageContext.request.contextPath}/harvests/create?tree_id=${tree.id}"
                   class="inline-flex items-center gap-1.5 px-3 py-2 rounded-lg border border-zinc-200 dark:border-zinc-700 bg-white dark:bg-zinc-800 text-xs font-semibold text-zinc-700 dark:text-zinc-200 hover:bg-zinc-50 dark:hover:bg-zinc-700">
                    ${h:icon('harvests')}
                    <span>Add harvest</span>
                </a>
            </c:if>
            <c:if test="${canWrite}">
                <a href="${pageContext.request.contextPath}/trees/${tree.id}/edit"
                   class="inline-flex items-center gap-1.5 px-3 py-2 rounded-lg bg-[var(--color-accent)] text-white text-xs font-semibold hover:opacity-90">
                    ${h:icon('pencil')}
                    <span>Edit</span>
                </a>
            </c:if>
            <c:if test="${isAdmin}">
                <form method="POST" action="${pageContext.request.contextPath}/trees/${tree.id}/delete" onsubmit="return confirm('Are you sure you want to delete this tree?');" class="inline">
                    <button type="submit" class="inline-flex items-center gap-1.5 px-3 py-2 rounded-lg bg-red-600 text-white text-xs font-semibold hover:bg-red-700 cursor-pointer">
                        ${h:icon('trash')}
                        <span>Delete</span>
                    </button>
                </form>
            </c:if>
        </div>
    </ui:header>

    <!-- Main Grid: Tree Info & Photo -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-8">
        <!-- Photo Card -->
        <div class="rounded-xl border border-zinc-200 bg-white p-5 shadow-xs dark:border-zinc-700 dark:bg-zinc-900 flex flex-col items-center justify-center">
            <c:choose>
                <c:when test="${tree.has_photo}">
                    <img src="${pageContext.request.contextPath}/trees/${tree.id}/photo" alt="Photo of ${tree.code}" class="w-full max-h-72 object-cover rounded-lg shadow-sm" />
                </c:when>
                <c:otherwise>
                    <div class="w-full h-48 bg-zinc-100 dark:bg-zinc-800 rounded-lg flex flex-col items-center justify-center text-zinc-400">
                        <div class="size-12 mb-2">${h:icon('tree')}</div>
                        <span class="text-xs">No photo available</span>
                    </div>
                </c:otherwise>
            </c:choose>
            <div class="mt-4 w-full flex items-center justify-between">
                <span class="text-xs text-zinc-500">Current Status:</span>
                <div>${h:statusBadge(tree.status)}</div>
            </div>
        </div>

        <!-- Details Card -->
        <div class="lg:col-span-2 rounded-xl border border-zinc-200 bg-white p-6 shadow-xs dark:border-zinc-700 dark:bg-zinc-900">
            <h2 class="text-base font-semibold text-zinc-800 dark:text-white mb-4">Tree Information</h2>
            <dl class="grid grid-cols-1 sm:grid-cols-2 gap-x-6 gap-y-4 text-sm">
                <div>
                    <dt class="text-xs font-semibold uppercase tracking-wider text-zinc-400">Tree Code</dt>
                    <dd class="mt-1 font-semibold text-zinc-900 dark:text-white">${h:e(tree.code)}</dd>
                </div>
                <div>
                    <dt class="text-xs font-semibold uppercase tracking-wider text-zinc-400">Category & Type</dt>
                    <dd class="mt-1 font-medium text-zinc-800 dark:text-zinc-200">${h:e(tree.category_name)} · ${h:e(tree.type_name)}</dd>
                </div>
                <div>
                    <dt class="text-xs font-semibold uppercase tracking-wider text-zinc-400">Block</dt>
                    <dd class="mt-1 font-medium text-zinc-800 dark:text-zinc-200">${h:e(tree.block_name)}</dd>
                </div>
                <div>
                    <dt class="text-xs font-semibold uppercase tracking-wider text-zinc-400">Planted On</dt>
                    <dd class="mt-1 font-medium text-zinc-800 dark:text-zinc-200">${h:date(tree.planted_on)}</dd>
                </div>
                <div>
                    <dt class="text-xs font-semibold uppercase tracking-wider text-zinc-400">Height</dt>
                    <dd class="mt-1 font-medium text-zinc-800 dark:text-zinc-200">${empty tree.height_cm ? '—' : tree.height_cm += ' cm'}</dd>
                </div>
                <div>
                    <dt class="text-xs font-semibold uppercase tracking-wider text-zinc-400">Recorded By</dt>
                    <dd class="mt-1 font-medium text-zinc-800 dark:text-zinc-200">${empty tree.author_name ? 'System' : h:e(tree.author_name)}</dd>
                </div>
                <div class="sm:col-span-2">
                    <dt class="text-xs font-semibold uppercase tracking-wider text-zinc-400">Notes</dt>
                    <dd class="mt-1 text-zinc-600 dark:text-zinc-300 whitespace-pre-line">${empty tree.notes ? 'No notes recorded.' : h:e(tree.notes)}</dd>
                </div>
            </dl>
        </div>
    </div>

    <!-- Timeline & Harvests Grid -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <!-- Care History -->
        <div class="rounded-xl border border-zinc-200 bg-white p-6 shadow-xs dark:border-zinc-700 dark:bg-zinc-900">
            <div class="flex items-center justify-between mb-4">
                <h2 class="text-base font-semibold text-zinc-800 dark:text-white">Care History</h2>
                <c:if test="${tree.status != 'dead' && canWrite}">
                    <a href="${pageContext.request.contextPath}/care-logs/create?tree_id=${tree.id}" class="text-xs font-medium text-[var(--color-accent-content)] hover:underline">+ Log care</a>
                </c:if>
            </div>
            <c:choose>
                <c:when test="${not empty careLogs}">
                    <div class="flow-root">
                        <ul class="-mb-8">
                            <c:forEach var="cl" items="${careLogs}" varStatus="status">
                                <li>
                                    <div class="relative pb-8">
                                        <c:if test="${!status.last}">
                                            <span class="absolute top-4 left-4 -ml-px h-full w-0.5 bg-zinc-200 dark:bg-zinc-700" aria-hidden="true"></span>
                                        </c:if>
                                        <div class="relative flex space-x-3">
                                            <div>
                                                <span class="h-8 w-8 rounded-full bg-green-50 text-green-700 flex items-center justify-center ring-8 ring-white dark:ring-zinc-900">
                                                    ${h:icon('care-logs')}
                                                </span>
                                            </div>
                                            <div class="flex-1 min-w-0 pt-1.5 flex justify-between space-x-4">
                                                <div>
                                                    <p class="text-sm font-semibold text-zinc-800 dark:text-white">${h:label(cl.activity_type)}</p>
                                                    <c:if test="${not empty cl.notes}">
                                                        <p class="text-xs text-zinc-500 mt-0.5">${h:e(cl.notes)}</p>
                                                    </c:if>
                                                </div>
                                                <div class="text-right text-xs whitespace-nowrap text-zinc-500">
                                                    <div>${h:date(cl.performed_on)}</div>
                                                    <c:if test="${not empty cl.next_due_on}">
                                                        <div class="text-amber-600 font-medium mt-0.5">Due: ${h:date(cl.next_due_on)}</div>
                                                    </c:if>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </li>
                            </c:forEach>
                        </ul>
                    </div>
                </c:when>
                <c:otherwise>
                    <p class="text-sm text-zinc-500 py-4 text-center">No care logs recorded yet.</p>
                </c:otherwise>
            </c:choose>
        </div>

        <!-- Harvest History -->
        <div class="rounded-xl border border-zinc-200 bg-white p-6 shadow-xs dark:border-zinc-700 dark:bg-zinc-900">
            <div class="flex items-center justify-between mb-4">
                <div>
                    <h2 class="text-base font-semibold text-zinc-800 dark:text-white">Harvest History</h2>
                    <p class="text-xs text-zinc-500 mt-0.5">Total: ${h:number(totalKg)} kg · ${h:number(totalPcs)} pcs</p>
                </div>
                <c:if test="${tree.status != 'dead' && canWrite}">
                    <a href="${pageContext.request.contextPath}/harvests/create?tree_id=${tree.id}" class="text-xs font-medium text-[var(--color-accent-content)] hover:underline">+ Log harvest</a>
                </c:if>
            </div>
            <c:choose>
                <c:when test="${not empty harvests}">
                    <div class="overflow-x-auto">
                        <table class="min-w-full text-left text-sm divide-y divide-zinc-200 dark:divide-zinc-700">
                            <thead>
                                <tr class="text-xs font-semibold text-zinc-500 uppercase tracking-wider">
                                    <th class="pb-3">Date</th>
                                    <th class="pb-3">Quantity</th>
                                    <th class="pb-3">Grade</th>
                                    <th class="pb-3 text-end">Recorded By</th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-zinc-100 dark:divide-zinc-800">
                                <c:forEach var="hItem" items="${harvests}">
                                    <tr>
                                        <td class="py-2.5 font-medium text-zinc-800 dark:text-white">${h:date(hItem.harvested_on)}</td>
                                        <td class="py-2.5 text-zinc-600 dark:text-zinc-300 font-semibold">${h:number(hItem.quantity)} ${h:e(hItem.unit)}</td>
                                        <td class="py-2.5">
                                            <span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-zinc-100 text-zinc-800 dark:bg-zinc-800 dark:text-zinc-200">
                                                ${h:label(hItem.grade)}
                                            </span>
                                        </td>
                                        <td class="py-2.5 text-end text-zinc-500 dark:text-zinc-400">${empty hItem.author_name ? 'System' : h:e(hItem.author_name)}</td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:when>
                <c:otherwise>
                    <p class="text-sm text-zinc-500 py-4 text-center">No harvests recorded yet.</p>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</ui:layout>
