<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="h" uri="https://harvesta.app/functions" %>

<ui:layout title="Harvests" active="harvests">
    <ui:header title="Harvests" description="Record fruit and crop yields by tree, quantity, unit, and grade.">
        <c:if test="${canWrite}">
            <a href="${pageContext.request.contextPath}/harvests/create"
               class="relative inline-flex items-center font-medium justify-center whitespace-nowrap h-10 text-sm rounded-lg gap-2 ps-3 pe-4 bg-[var(--color-accent)] hover:bg-[color-mix(in_oklab,_var(--color-accent),_transparent_10%)] text-[var(--color-accent-foreground)] border border-black/10 dark:border-0 shadow-[inset_0px_1px_--theme(--color-white/.2)]">
                ${h:icon('plus')}
                <span>Log harvest</span>
            </a>
        </c:if>
    </ui:header>

    <!-- Filters Card -->
    <div class="mb-6 rounded-xl border border-zinc-200 bg-white p-4 shadow-xs dark:border-zinc-700 dark:bg-zinc-900">
        <form method="GET" action="${pageContext.request.contextPath}/harvests" class="grid gap-4 sm:grid-cols-2 lg:grid-cols-5">
            <div>
                <label class="block text-xs font-semibold uppercase tracking-wider text-zinc-500 mb-1">Tree</label>
                <select name="tree_id" class="w-full block appearance-none text-sm rounded-lg py-2 h-10 px-3 bg-white dark:bg-white/10 text-zinc-700 dark:text-zinc-300 border-zinc-200 dark:border-white/10">
                    <option value="">All trees</option>
                    <c:forEach var="t" items="${trees}">
                        <option value="${t.id}" ${t.id == selectedTreeId ? 'selected' : ''}>${h:e(t.code)}</option>
                    </c:forEach>
                </select>
            </div>

            <div>
                <label class="block text-xs font-semibold uppercase tracking-wider text-zinc-500 mb-1">Block</label>
                <select name="block_id" class="w-full block appearance-none text-sm rounded-lg py-2 h-10 px-3 bg-white dark:bg-white/10 text-zinc-700 dark:text-zinc-300 border-zinc-200 dark:border-white/10">
                    <option value="">All blocks</option>
                    <c:forEach var="b" items="${blocks}">
                        <option value="${b.id}" ${b.id == selectedBlockId ? 'selected' : ''}>${h:e(b.name)}</option>
                    </c:forEach>
                </select>
            </div>

            <div>
                <label class="block text-xs font-semibold uppercase tracking-wider text-zinc-500 mb-1">Grade</label>
                <select name="grade" class="w-full block appearance-none text-sm rounded-lg py-2 h-10 px-3 bg-white dark:bg-white/10 text-zinc-700 dark:text-zinc-300 border-zinc-200 dark:border-white/10">
                    <option value="">All grades</option>
                    <c:forEach var="entry" items="${harvestGrades}">
                        <option value="${entry.key}" ${entry.key == selectedGrade ? 'selected' : ''}>${entry.value}</option>
                    </c:forEach>
                </select>
            </div>

            <div>
                <label class="block text-xs font-semibold uppercase tracking-wider text-zinc-500 mb-1">From Date</label>
                <input type="date" name="from" value="${from}"
                       class="w-full border block appearance-none text-sm rounded-lg py-2 h-10 px-3 bg-white dark:bg-white/10 text-zinc-700 dark:text-zinc-300 border-zinc-200 dark:border-white/10" />
            </div>

            <div class="flex items-end gap-2">
                <button type="submit" class="w-full h-10 text-sm font-medium rounded-lg bg-[var(--color-accent)] text-white hover:opacity-90">Filter</button>
                <a href="${pageContext.request.contextPath}/harvests" class="h-10 px-3 inline-flex items-center text-sm font-medium rounded-lg border border-zinc-200 dark:border-zinc-700 text-zinc-600 dark:text-zinc-300 hover:bg-zinc-50 dark:hover:bg-zinc-800">Reset</a>
            </div>
        </form>
    </div>

    <!-- Summary Banner -->
    <div class="mb-4 flex items-center justify-between px-1 text-sm text-zinc-600 dark:text-zinc-400">
        <div>Filtered totals: <span class="font-semibold text-zinc-900 dark:text-white">${h:number(totalKg)} kg</span> and <span class="font-semibold text-zinc-900 dark:text-white">${h:number(totalPcs)} pcs</span></div>
    </div>

    <!-- Harvests Table Card -->
    <div class="rounded-xl border border-zinc-200 bg-white p-5 shadow-xs dark:border-zinc-700 dark:bg-zinc-900">
        <c:choose>
            <c:when test="${not empty harvests}">
                <div class="overflow-x-auto">
                    <table class="[:where(&)]:min-w-full table-fixed border-separate border-spacing-0 isolate text-zinc-800 dark:text-zinc-200 whitespace-nowrap" data-flux-table>
                        <thead>
                            <tr class="text-xs font-semibold uppercase tracking-wider text-zinc-500 border-b border-zinc-200 dark:border-zinc-700">
                                <th class="py-3 px-3 text-start">Tree</th>
                                <th class="py-3 px-3 text-start">Type & Block</th>
                                <th class="py-3 px-3 text-start">Quantity</th>
                                <th class="py-3 px-3 text-start">Grade</th>
                                <th class="py-3 px-3 text-start">Harvested on</th>
                                <th class="py-3 px-3 text-start">Sales Status</th>
                                <th class="py-3 px-3 text-start">Recorded by</th>
                                <th class="py-3 px-3 text-end">Actions</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-zinc-100 dark:divide-zinc-800 text-sm">
                            <c:forEach var="hItem" items="${harvests}">
                                <tr class="hover:bg-zinc-50 dark:hover:bg-zinc-800/50 transition-colors">
                                    <td class="py-3 px-3 font-semibold">
                                        <a href="${pageContext.request.contextPath}/trees/${hItem.tree_id}" class="text-[var(--color-accent-content)] hover:underline">${h:e(hItem.tree_code)}</a>
                                    </td>
                                    <td class="py-3 px-3 text-zinc-600 dark:text-zinc-400">${h:e(hItem.type_name)} (${h:e(hItem.block_name)})</td>
                                    <td class="py-3 px-3 font-semibold text-zinc-900 dark:text-white">${h:number(hItem.quantity)} ${h:e(hItem.unit)}</td>
                                    <td class="py-3 px-3">
                                        <span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-zinc-100 text-zinc-800 dark:bg-zinc-800 dark:text-zinc-200">
                                            ${h:label(hItem.grade)}
                                        </span>
                                    </td>
                                    <td class="py-3 px-3 text-zinc-600 dark:text-zinc-400">${h:date(hItem.harvested_on)}</td>
                                    <td class="py-3 px-3">
                                        <c:choose>
                                            <c:when test="${hItem.sold_qty >= hItem.quantity}">
                                                <span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-green-100 text-green-800 dark:bg-green-900/40 dark:text-green-300">Fully sold</span>
                                            </c:when>
                                            <c:when test="${hItem.sold_qty > 0}">
                                                <span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-amber-100 text-amber-800 dark:bg-amber-900/40 dark:text-amber-300">Partially sold (${h:number(hItem.sold_qty)}/${h:number(hItem.quantity)})</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-zinc-100 text-zinc-600 dark:bg-zinc-800 dark:text-zinc-400">Unsold</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="py-3 px-3 text-zinc-500 dark:text-zinc-400">${empty hItem.author_name ? 'System' : h:e(hItem.author_name)}</td>
                                    <td class="py-3 px-3 text-end">
                                        <div class="inline-flex items-center gap-2">
                                            <c:if test="${isAdmin || (hItem.user_id == userId && canWrite)}">
                                                <a href="${pageContext.request.contextPath}/harvests/${hItem.id}/edit" class="p-1 text-zinc-500 hover:text-zinc-800 dark:hover:text-white" title="Edit harvest">
                                                    ${h:icon('pencil')}
                                                </a>
                                            </c:if>
                                            <c:if test="${isAdmin}">
                                                <form method="POST" action="${pageContext.request.contextPath}/harvests/${hItem.id}/delete" onsubmit="return confirm('Are you sure you want to delete this harvest?');" class="inline">
                                                    <button type="submit" class="p-1 text-red-500 hover:text-red-700 cursor-pointer" title="Delete harvest">
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

                <ui:pagination currentPage="${currentPage}" totalPages="${totalPages}" totalCount="${totalCount}" pageSize="${pageSize}" queryString="${queryString}" />
            </c:when>
            <c:otherwise>
                <ui:empty title="No harvests found" description="Try adjusting your filters or record a new harvest.">
                    <c:if test="${canWrite}">
                        <a href="${pageContext.request.contextPath}/harvests/create" class="inline-flex items-center px-4 py-2 rounded-lg bg-[var(--color-accent)] text-white text-sm font-medium">Log harvest</a>
                    </c:if>
                </ui:empty>
            </c:otherwise>
        </c:choose>
    </div>
</ui:layout>
