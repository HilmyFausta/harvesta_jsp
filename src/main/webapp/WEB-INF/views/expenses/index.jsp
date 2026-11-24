<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="h" uri="https://harvesta.app/functions" %>

<ui:layout title="Expenses" active="expenses">
    <ui:header title="Expenses" description="Operational costs including fertilizer, labor, equipment, and fuel.">
        <a href="${pageContext.request.contextPath}/expenses/create"
           class="relative inline-flex items-center font-medium justify-center whitespace-nowrap h-10 text-sm rounded-lg gap-2 ps-3 pe-4 bg-[var(--color-accent)] hover:bg-[color-mix(in_oklab,_var(--color-accent),_transparent_10%)] text-[var(--color-accent-foreground)] border border-black/10 dark:border-0 shadow-[inset_0px_1px_--theme(--color-white/.2)]">
            ${h:icon('plus')}
            <span>Record expense</span>
        </a>
    </ui:header>

    <!-- Filters Card -->
    <div class="mb-6 rounded-xl border border-zinc-200 bg-white p-4 shadow-xs dark:border-zinc-700 dark:bg-zinc-900">
        <form method="GET" action="${pageContext.request.contextPath}/expenses" class="grid gap-4 sm:grid-cols-2 lg:grid-cols-5">
            <div>
                <label class="block text-xs font-semibold uppercase tracking-wider text-zinc-500 mb-1">Block</label>
                <select name="block_id" class="w-full block appearance-none text-sm rounded-lg py-2 h-10 px-3 bg-white dark:bg-white/10 text-zinc-700 dark:text-zinc-300 border-zinc-200 dark:border-white/10">
                    <option value="">All expenses</option>
                    <option value="general" ${selectedBlock == 'general' ? 'selected' : ''}>General Farm (No Block)</option>
                    <c:forEach var="b" items="${blocks}">
                        <option value="${b.id}" ${b.id.toString() == selectedBlock ? 'selected' : ''}>${h:e(b.name)}</option>
                    </c:forEach>
                </select>
            </div>

            <div>
                <label class="block text-xs font-semibold uppercase tracking-wider text-zinc-500 mb-1">Category</label>
                <select name="category" class="w-full block appearance-none text-sm rounded-lg py-2 h-10 px-3 bg-white dark:bg-white/10 text-zinc-700 dark:text-zinc-300 border-zinc-200 dark:border-white/10">
                    <option value="">All categories</option>
                    <c:forEach var="entry" items="${categories}">
                        <option value="${entry.key}" ${entry.key == selectedCategory ? 'selected' : ''}>${entry.value}</option>
                    </c:forEach>
                </select>
            </div>

            <div>
                <label class="block text-xs font-semibold uppercase tracking-wider text-zinc-500 mb-1">From Date</label>
                <input type="date" name="from" value="${from}"
                       class="w-full border block appearance-none text-sm rounded-lg py-2 h-10 px-3 bg-white dark:bg-white/10 text-zinc-700 dark:text-zinc-300 border-zinc-200 dark:border-white/10" />
            </div>

            <div>
                <label class="block text-xs font-semibold uppercase tracking-wider text-zinc-500 mb-1">To Date</label>
                <input type="date" name="to" value="${to}"
                       class="w-full border block appearance-none text-sm rounded-lg py-2 h-10 px-3 bg-white dark:bg-white/10 text-zinc-700 dark:text-zinc-300 border-zinc-200 dark:border-white/10" />
            </div>

            <div class="flex items-end gap-2">
                <button type="submit" class="w-full h-10 text-sm font-medium rounded-lg bg-[var(--color-accent)] text-white hover:opacity-90">Filter</button>
                <a href="${pageContext.request.contextPath}/expenses" class="h-10 px-3 inline-flex items-center text-sm font-medium rounded-lg border border-zinc-200 dark:border-zinc-700 text-zinc-600 dark:text-zinc-300 hover:bg-zinc-50 dark:hover:bg-zinc-800">Reset</a>
            </div>
        </form>
    </div>

    <!-- Summary Banner -->
    <div class="mb-4 flex items-center justify-between px-1 text-sm text-zinc-600 dark:text-zinc-400">
        <div>Total Expenses: <span class="font-bold text-red-600 dark:text-red-400">${h:money(totalAmount)}</span></div>
    </div>

    <!-- Expenses Table Card -->
    <div class="rounded-xl border border-zinc-200 bg-white p-5 shadow-xs dark:border-zinc-700 dark:bg-zinc-900">
        <c:choose>
            <c:when test="${not empty expenses}">
                <div class="overflow-x-auto">
                    <table class="[:where(&)]:min-w-full table-fixed border-separate border-spacing-0 isolate text-zinc-800 dark:text-zinc-200 whitespace-nowrap" data-flux-table>
                        <thead>
                            <tr class="text-xs font-semibold uppercase tracking-wider text-zinc-500 border-b border-zinc-200 dark:border-zinc-700">
                                <th class="py-3 px-3 text-start">Date</th>
                                <th class="py-3 px-3 text-start">Category</th>
                                <th class="py-3 px-3 text-start">Block</th>
                                <th class="py-3 px-3 text-start">Description</th>
                                <th class="py-3 px-3 text-start">Amount</th>
                                <th class="py-3 px-3 text-start">Recorded by</th>
                                <th class="py-3 px-3 text-end">Actions</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-zinc-100 dark:divide-zinc-800 text-sm">
                            <c:forEach var="e" items="${expenses}">
                                <tr class="hover:bg-zinc-50 dark:hover:bg-zinc-800/50 transition-colors">
                                    <td class="py-3 px-3 font-medium text-zinc-900 dark:text-white">${h:date(e.spent_on)}</td>
                                    <td class="py-3 px-3">
                                        <span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-zinc-100 text-zinc-800 dark:bg-zinc-800 dark:text-zinc-200">
                                            ${h:label(e.category)}
                                        </span>
                                    </td>
                                    <td class="py-3 px-3 text-zinc-600 dark:text-zinc-400">${empty e.block_name ? 'General farm' : h:e(e.block_name)}</td>
                                    <td class="py-3 px-3 text-zinc-600 dark:text-zinc-400 max-w-xs truncate">${empty e.description ? '—' : h:e(e.description)}</td>
                                    <td class="py-3 px-3 font-semibold text-red-600 dark:text-red-400">${h:money(e.amount)}</td>
                                    <td class="py-3 px-3 text-zinc-500 dark:text-zinc-400">${empty e.author_name ? 'System' : h:e(e.author_name)}</td>
                                    <td class="py-3 px-3 text-end">
                                        <div class="inline-flex items-center gap-2">
                                            <a href="${pageContext.request.contextPath}/expenses/${e.id}/edit" class="p-1 text-zinc-500 hover:text-zinc-800 dark:hover:text-white" title="Edit expense">
                                                ${h:icon('pencil')}
                                            </a>
                                            <form method="POST" action="${pageContext.request.contextPath}/expenses/${e.id}/delete" onsubmit="return confirm('Are you sure you want to delete this expense?');" class="inline">
                                                <button type="submit" class="p-1 text-red-500 hover:text-red-700 cursor-pointer" title="Delete expense">
                                                    ${h:icon('trash')}
                                                </button>
                                            </form>
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
                <ui:empty title="No expenses recorded" description="Track farm spending by recording expenses.">
                    <a href="${pageContext.request.contextPath}/expenses/create" class="inline-flex items-center px-4 py-2 rounded-lg bg-[var(--color-accent)] text-white text-sm font-medium">Record expense</a>
                </ui:empty>
            </c:otherwise>
        </c:choose>
    </div>
</ui:layout>
