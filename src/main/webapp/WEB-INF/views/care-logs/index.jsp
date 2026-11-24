<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="h" uri="https://harvesta.app/functions" %>

<ui:layout title="Care Logs" active="care-logs">
    <ui:header title="Care Logs" description="Keep track of watering, pruning, treatments, and other tree maintenance.">
        <c:if test="${canWrite}">
            <a href="${pageContext.request.contextPath}/care-logs/create"
               class="relative inline-flex items-center font-medium justify-center whitespace-nowrap h-10 text-sm rounded-lg gap-2 ps-3 pe-4 bg-[var(--color-accent)] hover:bg-[color-mix(in_oklab,_var(--color-accent),_transparent_10%)] text-[var(--color-accent-foreground)] border border-black/10 dark:border-0 shadow-[inset_0px_1px_--theme(--color-white/.2)]">
                ${h:icon('plus')}
                <span>Log care activity</span>
            </a>
        </c:if>
    </ui:header>

    <!-- Filters Card -->
    <div class="mb-6 rounded-xl border border-zinc-200 bg-white p-4 shadow-xs dark:border-zinc-700 dark:bg-zinc-900">
        <form method="GET" action="${pageContext.request.contextPath}/care-logs" class="grid gap-4 sm:grid-cols-2 lg:grid-cols-5">
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
                <label class="block text-xs font-semibold uppercase tracking-wider text-zinc-500 mb-1">Activity</label>
                <select name="activity_type" class="w-full block appearance-none text-sm rounded-lg py-2 h-10 px-3 bg-white dark:bg-white/10 text-zinc-700 dark:text-zinc-300 border-zinc-200 dark:border-white/10">
                    <option value="">All activities</option>
                    <c:forEach var="entry" items="${activityTypes}">
                        <option value="${entry.key}" ${entry.key == selectedActivity ? 'selected' : ''}>${entry.value}</option>
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
                <a href="${pageContext.request.contextPath}/care-logs" class="h-10 px-3 inline-flex items-center text-sm font-medium rounded-lg border border-zinc-200 dark:border-zinc-700 text-zinc-600 dark:text-zinc-300 hover:bg-zinc-50 dark:hover:bg-zinc-800">Reset</a>
            </div>
        </form>
    </div>

    <!-- Care Logs Table Card -->
    <div class="rounded-xl border border-zinc-200 bg-white p-5 shadow-xs dark:border-zinc-700 dark:bg-zinc-900">
        <c:choose>
            <c:when test="${not empty careLogs}">
                <div class="overflow-x-auto">
                    <table class="[:where(&)]:min-w-full table-fixed border-separate border-spacing-0 isolate text-zinc-800 dark:text-zinc-200 whitespace-nowrap" data-flux-table>
                        <thead>
                            <tr class="text-xs font-semibold uppercase tracking-wider text-zinc-500 border-b border-zinc-200 dark:border-zinc-700">
                                <th class="py-3 px-3 text-start">Tree</th>
                                <th class="py-3 px-3 text-start">Block</th>
                                <th class="py-3 px-3 text-start">Activity</th>
                                <th class="py-3 px-3 text-start">Performed on</th>
                                <th class="py-3 px-3 text-start">Next due</th>
                                <th class="py-3 px-3 text-start">Recorded by</th>
                                <th class="py-3 px-3 text-end">Actions</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-zinc-100 dark:divide-zinc-800 text-sm">
                            <c:forEach var="cl" items="${careLogs}">
                                <tr class="hover:bg-zinc-50 dark:hover:bg-zinc-800/50 transition-colors">
                                    <td class="py-3 px-3 font-semibold">
                                        <a href="${pageContext.request.contextPath}/trees/${cl.tree_id}" class="text-[var(--color-accent-content)] hover:underline">${h:e(cl.tree_code)}</a>
                                    </td>
                                    <td class="py-3 px-3 text-zinc-600 dark:text-zinc-400">${h:e(cl.block_name)}</td>
                                    <td class="py-3 px-3 font-medium text-zinc-800 dark:text-zinc-100">${h:label(cl.activity_type)}</td>
                                    <td class="py-3 px-3 text-zinc-600 dark:text-zinc-400">${h:date(cl.performed_on)}</td>
                                    <td class="py-3 px-3 text-zinc-600 dark:text-zinc-400">${empty cl.next_due_on ? '—' : h:date(cl.next_due_on)}</td>
                                    <td class="py-3 px-3 text-zinc-500 dark:text-zinc-400">${empty cl.author_name ? 'System' : h:e(cl.author_name)}</td>
                                    <td class="py-3 px-3 text-end">
                                        <div class="inline-flex items-center gap-2">
                                            <c:if test="${isAdmin || (cl.user_id == userId && canWrite)}">
                                                <a href="${pageContext.request.contextPath}/care-logs/${cl.id}/edit" class="p-1 text-zinc-500 hover:text-zinc-800 dark:hover:text-white" title="Edit care log">
                                                    ${h:icon('pencil')}
                                                </a>
                                            </c:if>
                                            <c:if test="${isAdmin}">
                                                <form method="POST" action="${pageContext.request.contextPath}/care-logs/${cl.id}/delete" onsubmit="return confirm('Are you sure you want to delete this care log?');" class="inline">
                                                    <button type="submit" class="p-1 text-red-500 hover:text-red-700 cursor-pointer" title="Delete care log">
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
                <ui:empty title="No care logs found" description="Try adjusting your filters or record a new care activity.">
                    <c:if test="${canWrite}">
                        <a href="${pageContext.request.contextPath}/care-logs/create" class="inline-flex items-center px-4 py-2 rounded-lg bg-[var(--color-accent)] text-white text-sm font-medium">Log care activity</a>
                    </c:if>
                </ui:empty>
            </c:otherwise>
        </c:choose>
    </div>
</ui:layout>
