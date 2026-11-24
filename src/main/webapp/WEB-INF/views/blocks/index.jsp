<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="h" uri="https://harvesta.app/functions" %>

<ui:layout title="Blocks" active="blocks">
    <ui:header title="Blocks" description="Planting zones and physical parcels of land in the orchard.">
        <c:if test="${isAdmin}">
            <a href="${pageContext.request.contextPath}/blocks/create"
               class="relative inline-flex items-center font-medium justify-center whitespace-nowrap h-10 text-sm rounded-lg gap-2 ps-3 pe-4 bg-[var(--color-accent)] hover:bg-[color-mix(in_oklab,_var(--color-accent),_transparent_10%)] text-[var(--color-accent-foreground)] border border-black/10 dark:border-0 shadow-[inset_0px_1px_--theme(--color-white/.2)]">
                ${h:icon('plus')}
                <span>Add block</span>
            </a>
        </c:if>
    </ui:header>

    <div class="rounded-xl border border-zinc-200 bg-white p-5 shadow-xs dark:border-zinc-700 dark:bg-zinc-900">
        <c:choose>
            <c:when test="${not empty blocks}">
                <div class="overflow-x-auto">
                    <table class="[:where(&)]:min-w-full table-fixed border-separate border-spacing-0 isolate text-zinc-800 dark:text-zinc-200 whitespace-nowrap" data-flux-table>
                        <thead>
                            <tr class="text-xs font-semibold uppercase tracking-wider text-zinc-500 border-b border-zinc-200 dark:border-zinc-700">
                                <th class="py-3 px-3 text-start">Block</th>
                                <th class="py-3 px-3 text-start">Area (m²)</th>
                                <th class="py-3 px-3 text-start">Location Note</th>
                                <th class="py-3 px-3 text-start">Planted Trees</th>
                                <th class="py-3 px-3 text-start">Total Harvest (kg)</th>
                                <th class="py-3 px-3 text-end">Actions</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-zinc-100 dark:divide-zinc-800 text-sm">
                            <c:forEach var="b" items="${blocks}">
                                <tr class="hover:bg-zinc-50 dark:hover:bg-zinc-800/50 transition-colors">
                                    <td class="py-3 px-3 font-semibold">
                                        <a href="${pageContext.request.contextPath}/blocks/${b.id}" class="text-[var(--color-accent-content)] hover:underline">${h:e(b.name)}</a>
                                    </td>
                                    <td class="py-3 px-3 text-zinc-600 dark:text-zinc-400">${empty b.area_sqm ? '—' : h:number(b.area_sqm)}</td>
                                    <td class="py-3 px-3 text-zinc-500 dark:text-zinc-400">${empty b.location_note ? '—' : h:e(b.location_note)}</td>
                                    <td class="py-3 px-3">
                                        <a href="${pageContext.request.contextPath}/trees?block_id=${b.id}" class="text-[var(--color-accent-content)] hover:underline font-medium">
                                            ${b.tree_count} ${b.tree_count == 1 ? 'tree' : 'trees'}
                                        </a>
                                    </td>
                                    <td class="py-3 px-3 font-medium text-zinc-700 dark:text-zinc-200">${h:number(b.total_kg)}</td>
                                    <td class="py-3 px-3 text-end">
                                        <div class="inline-flex items-center gap-2">
                                            <a href="${pageContext.request.contextPath}/blocks/${b.id}" class="p-1 text-zinc-500 hover:text-zinc-800 dark:hover:text-white" title="View details">
                                                ${h:icon('eye')}
                                            </a>
                                            <c:if test="${isAdmin}">
                                                <a href="${pageContext.request.contextPath}/blocks/${b.id}/edit" class="p-1 text-zinc-500 hover:text-zinc-800 dark:hover:text-white" title="Edit block">
                                                    ${h:icon('pencil')}
                                                </a>
                                                <form method="POST" action="${pageContext.request.contextPath}/blocks/${b.id}/delete" onsubmit="return confirm('Are you sure you want to delete this block?');" class="inline">
                                                    <button type="submit" class="p-1 text-red-500 hover:text-red-700 cursor-pointer" title="Delete block">
                                                        ${h:icon('trash')}
                                                    </button>
                                                </form>
                                            </c:if>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </c:when>
            <c:otherwise>
                <ui:empty title="No blocks found" description="Add blocks to delineate planting parcels.">
                    <c:if test="${isAdmin}">
                        <a href="${pageContext.request.contextPath}/blocks/create" class="inline-flex items-center px-4 py-2 rounded-lg bg-[var(--color-accent)] text-white text-sm font-medium">Add block</a>
                    </c:if>
                </ui:empty>
            </c:otherwise>
        </c:choose>
    </div>
</ui:layout>
