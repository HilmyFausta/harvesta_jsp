<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="h" uri="https://harvesta.app/functions" %>

<ui:layout title="Trees" active="trees">
    <ui:header title="Trees" description="Every tree in the orchard, with its type, block, and current status.">
        <c:if test="${canWrite}">
            <a href="${pageContext.request.contextPath}/trees/create"
               class="relative inline-flex items-center font-medium justify-center whitespace-nowrap h-10 text-sm rounded-lg gap-2 ps-3 pe-4 bg-[var(--color-accent)] hover:bg-[color-mix(in_oklab,_var(--color-accent),_transparent_10%)] text-[var(--color-accent-foreground)] border border-black/10 dark:border-0 shadow-[inset_0px_1px_--theme(--color-white/.2)]">
                ${h:icon('plus')}
                <span>Add tree</span>
            </a>
        </c:if>
    </ui:header>

    <!-- Search & Filters Card -->
    <div class="mb-6 rounded-xl border border-zinc-200 bg-white p-4 shadow-xs dark:border-zinc-700 dark:bg-zinc-900">
        <form method="GET" action="${pageContext.request.contextPath}/trees" class="grid gap-4 sm:grid-cols-2 lg:grid-cols-5">
            <div>
                <label class="block text-xs font-semibold uppercase tracking-wider text-zinc-500 mb-1">Search</label>
                <input type="text" name="search" value="${h:e(search)}" placeholder="Code or notes..."
                       class="w-full border block appearance-none text-sm rounded-lg py-2 h-10 px-3 bg-white dark:bg-white/10 text-zinc-700 dark:text-zinc-300 placeholder-zinc-400 border-zinc-200 dark:border-white/10" />
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
                <label class="block text-xs font-semibold uppercase tracking-wider text-zinc-500 mb-1">Tree Type</label>
                <select name="tree_type_id" class="w-full block appearance-none text-sm rounded-lg py-2 h-10 px-3 bg-white dark:bg-white/10 text-zinc-700 dark:text-zinc-300 border-zinc-200 dark:border-white/10">
                    <option value="">All tree types</option>
                    <c:forEach var="tt" items="${treeTypes}">
                        <option value="${tt.id}" ${tt.id == selectedTypeId ? 'selected' : ''}>${h:e(tt.name)}</option>
                    </c:forEach>
                </select>
            </div>

            <div>
                <label class="block text-xs font-semibold uppercase tracking-wider text-zinc-500 mb-1">Status</label>
                <select name="status" class="w-full block appearance-none text-sm rounded-lg py-2 h-10 px-3 bg-white dark:bg-white/10 text-zinc-700 dark:text-zinc-300 border-zinc-200 dark:border-white/10">
                    <option value="">All statuses</option>
                    <c:forEach var="entry" items="${treeStatuses}">
                        <option value="${entry.key}" ${entry.key == selectedStatus ? 'selected' : ''}>${entry.value}</option>
                    </c:forEach>
                </select>
            </div>

            <div class="flex items-end gap-2">
                <button type="submit" class="w-full h-10 text-sm font-medium rounded-lg bg-[var(--color-accent)] text-white hover:opacity-90">Filter</button>
                <a href="${pageContext.request.contextPath}/trees" class="h-10 px-3 inline-flex items-center text-sm font-medium rounded-lg border border-zinc-200 dark:border-zinc-700 text-zinc-600 dark:text-zinc-300 hover:bg-zinc-50 dark:hover:bg-zinc-800">Reset</a>
            </div>
        </form>
    </div>

    <!-- Trees Table Card -->
    <div class="rounded-xl border border-zinc-200 bg-white p-5 shadow-xs dark:border-zinc-700 dark:bg-zinc-900">
        <c:choose>
            <c:when test="${not empty trees}">
                <div class="overflow-x-auto">
                    <table class="[:where(&)]:min-w-full table-fixed border-separate border-spacing-0 isolate text-zinc-800 dark:text-zinc-200 whitespace-nowrap" data-flux-table>
                        <thead>
                            <tr class="text-xs font-semibold uppercase tracking-wider text-zinc-500 border-b border-zinc-200 dark:border-zinc-700">
                                <th class="py-3 px-3 text-start">Tree</th>
                                <th class="py-3 px-3 text-start">Type</th>
                                <th class="py-3 px-3 text-start">Block</th>
                                <th class="py-3 px-3 text-start">Planted on</th>
                                <th class="py-3 px-3 text-start">Status</th>
                                <th class="py-3 px-3 text-end">Actions</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-zinc-100 dark:divide-zinc-800 text-sm">
                            <c:forEach var="t" items="${trees}">
                                <tr class="hover:bg-zinc-50 dark:hover:bg-zinc-800/50 transition-colors">
                                    <td class="py-3 px-3">
                                        <a href="${pageContext.request.contextPath}/trees/${t.id}" class="flex items-center gap-3">
                                            <c:choose>
                                                <c:when test="${t.has_photo}">
                                                    <img src="${pageContext.request.contextPath}/trees/${t.id}/photo" alt="Photo" class="size-10 shrink-0 rounded-lg object-cover" />
                                                </c:when>
                                                <c:otherwise>
                                                    <div class="size-10 shrink-0 rounded-lg bg-zinc-100 dark:bg-zinc-800 flex items-center justify-center text-zinc-400">
                                                        ${h:icon('tree')}
                                                    </div>
                                                </c:otherwise>
                                            </c:choose>
                                            <span class="font-semibold text-[var(--color-accent-content)] hover:underline">${h:e(t.code)}</span>
                                        </a>
                                    </td>
                                    <td class="py-3 px-3 font-medium text-zinc-700 dark:text-zinc-200">${h:e(t.type_name)}</td>
                                    <td class="py-3 px-3 text-zinc-600 dark:text-zinc-400">${h:e(t.block_name)}</td>
                                    <td class="py-3 px-3 text-zinc-600 dark:text-zinc-400">${h:date(t.planted_on)}</td>
                                    <td class="py-3 px-3">${h:statusBadge(t.status)}</td>
                                    <td class="py-3 px-3 text-end">
                                        <div class="inline-flex items-center gap-2">
                                            <a href="${pageContext.request.contextPath}/trees/${t.id}" class="p-1 text-zinc-500 hover:text-zinc-800 dark:hover:text-white" title="View details">
                                                ${h:icon('eye')}
                                            </a>
                                            <c:if test="${canWrite}">
                                                <a href="${pageContext.request.contextPath}/trees/${t.id}/edit" class="p-1 text-zinc-500 hover:text-zinc-800 dark:hover:text-white" title="Edit tree">
                                                    ${h:icon('pencil')}
                                                </a>
                                            </c:if>
                                            <c:if test="${isAdmin}">
                                                <form method="POST" action="${pageContext.request.contextPath}/trees/${t.id}/delete" onsubmit="return confirm('Are you sure you want to delete this tree?');" class="inline">
                                                    <button type="submit" class="p-1 text-red-500 hover:text-red-700 cursor-pointer" title="Delete tree">
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
                <ui:empty title="No trees found" description="Try adjusting your search or filters, or add a new tree to the orchard.">
                    <c:if test="${canWrite}">
                        <a href="${pageContext.request.contextPath}/trees/create" class="inline-flex items-center px-4 py-2 rounded-lg bg-[var(--color-accent)] text-white text-sm font-medium">Add tree</a>
                    </c:if>
                </ui:empty>
            </c:otherwise>
        </c:choose>
    </div>
</ui:layout>
