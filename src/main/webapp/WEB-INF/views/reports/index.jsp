<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="h" uri="https://harvesta.app/functions" %>

<ui:layout title="Reports" active="reports" charts="true">
    <ui:header title="Reports" description="Comprehensive summaries for harvests, farm financials, and care activities.">
        <a href="${pageContext.request.contextPath}/reports/export?report=${reportType}&from=${from}&to=${to}"
           class="relative inline-flex items-center font-medium justify-center whitespace-nowrap h-10 text-sm rounded-lg gap-2 ps-3 pe-4 bg-white dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-700 dark:text-zinc-200 hover:bg-zinc-50 dark:hover:bg-zinc-700 shadow-xs">
            <svg class="size-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4"/></svg>
            <span>Export CSV</span>
        </a>
    </ui:header>

    <!-- Report Type Tabs & Filter -->
    <div class="mb-6 rounded-xl border border-zinc-200 bg-white p-4 shadow-xs dark:border-zinc-700 dark:bg-zinc-900">
        <div class="flex flex-wrap items-center justify-between gap-4">
            <!-- Tabs -->
            <div class="flex items-center gap-1 p-1 bg-zinc-100 dark:bg-zinc-800 rounded-lg text-sm font-medium">
                <a href="${pageContext.request.contextPath}/reports?report=harvest&from=${from}&to=${to}"
                   class="px-3 py-1.5 rounded-md ${reportType == 'harvest' ? 'bg-white dark:bg-zinc-700 text-zinc-900 dark:text-white shadow-xs' : 'text-zinc-600 dark:text-zinc-400 hover:text-zinc-900'}">
                    Harvest Summary
                </a>
                <a href="${pageContext.request.contextPath}/reports?report=financial&from=${from}&to=${to}"
                   class="px-3 py-1.5 rounded-md ${reportType == 'financial' ? 'bg-white dark:bg-zinc-700 text-zinc-900 dark:text-white shadow-xs' : 'text-zinc-600 dark:text-zinc-400 hover:text-zinc-900'}">
                    Financial Summary
                </a>
                <a href="${pageContext.request.contextPath}/reports?report=care&from=${from}&to=${to}"
                   class="px-3 py-1.5 rounded-md ${reportType == 'care' ? 'bg-white dark:bg-zinc-700 text-zinc-900 dark:text-white shadow-xs' : 'text-zinc-600 dark:text-zinc-400 hover:text-zinc-900'}">
                    Care Activity
                </a>
            </div>

            <!-- Date Form -->
            <form method="GET" action="${pageContext.request.contextPath}/reports" class="flex items-center gap-3">
                <input type="hidden" name="report" value="${reportType}" />
                <div class="flex items-center gap-2">
                    <label class="text-xs font-semibold text-zinc-500 uppercase">From</label>
                    <input type="date" name="from" value="${from}" class="text-sm rounded-lg border border-zinc-200 dark:border-zinc-700 bg-white dark:bg-zinc-800 px-2 py-1.5" />
                </div>
                <div class="flex items-center gap-2">
                    <label class="text-xs font-semibold text-zinc-500 uppercase">To</label>
                    <input type="date" name="to" value="${to}" class="text-sm rounded-lg border border-zinc-200 dark:border-zinc-700 bg-white dark:bg-zinc-800 px-2 py-1.5" />
                </div>
                <button type="submit" class="px-3 py-1.5 rounded-lg bg-[var(--color-accent)] text-white text-sm font-medium">Apply</button>
            </form>
        </div>
    </div>

    <!-- Report Table Content -->
    <div class="rounded-xl border border-zinc-200 bg-white p-5 shadow-xs dark:border-zinc-700 dark:bg-zinc-900">
        <c:choose>
            <c:when test="${reportType == 'financial'}">
                <div class="mb-4 flex items-center justify-between text-sm">
                    <div class="flex gap-4">
                        <span>Total Sales: <strong class="text-green-700 dark:text-green-400">${h:money(totalSales)}</strong></span>
                        <span>Total Expenses: <strong class="text-red-700 dark:text-red-400">${h:money(totalExpenses)}</strong></span>
                        <span>Net Profit: <strong class="${totalNet >= 0 ? 'text-green-700 dark:text-green-400' : 'text-red-700 dark:text-red-400'}">${h:money(totalNet)}</strong></span>
                    </div>
                </div>
                <div class="overflow-x-auto">
                    <table class="[:where(&)]:min-w-full table-fixed border-separate border-spacing-0 isolate text-zinc-800 dark:text-zinc-200 whitespace-nowrap" data-flux-table>
                        <thead>
                            <tr class="text-xs font-semibold uppercase tracking-wider text-zinc-500 border-b border-zinc-200 dark:border-zinc-700">
                                <th class="py-3 px-3 text-start">Month</th>
                                <th class="py-3 px-3 text-end">Sales (Revenue)</th>
                                <th class="py-3 px-3 text-end">Expenses</th>
                                <th class="py-3 px-3 text-end">Net Profit</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-zinc-100 dark:divide-zinc-800 text-sm">
                            <c:forEach var="row" items="${financialRows}">
                                <tr class="hover:bg-zinc-50 dark:hover:bg-zinc-800/50">
                                    <td class="py-3 px-3 font-semibold text-zinc-900 dark:text-white">${row.month}</td>
                                    <td class="py-3 px-3 text-end text-green-700 dark:text-green-400 font-medium">${h:money(row.sales)}</td>
                                    <td class="py-3 px-3 text-end text-red-700 dark:text-red-400 font-medium">${h:money(row.expenses)}</td>
                                    <td class="py-3 px-3 text-end font-semibold ${row.net >= 0 ? 'text-green-700 dark:text-green-400' : 'text-red-700 dark:text-red-400'}">${h:money(row.net)}</td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </c:when>

            <c:when test="${reportType == 'care'}">
                <div class="overflow-x-auto">
                    <table class="[:where(&)]:min-w-full table-fixed border-separate border-spacing-0 isolate text-zinc-800 dark:text-zinc-200 whitespace-nowrap" data-flux-table>
                        <thead>
                            <tr class="text-xs font-semibold uppercase tracking-wider text-zinc-500 border-b border-zinc-200 dark:border-zinc-700">
                                <th class="py-3 px-3 text-start">Activity Type</th>
                                <th class="py-3 px-3 text-start">Times Performed</th>
                                <th class="py-3 px-3 text-start">First Date</th>
                                <th class="py-3 px-3 text-start">Latest Date</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-zinc-100 dark:divide-zinc-800 text-sm">
                            <c:forEach var="row" items="${careRows}">
                                <tr class="hover:bg-zinc-50 dark:hover:bg-zinc-800/50">
                                    <td class="py-3 px-3 font-semibold text-zinc-900 dark:text-white">${h:label(row.activity_type)}</td>
                                    <td class="py-3 px-3 font-medium text-zinc-700 dark:text-zinc-300">${row.count} times</td>
                                    <td class="py-3 px-3 text-zinc-500">${h:date(row.first_date)}</td>
                                    <td class="py-3 px-3 text-zinc-500">${h:date(row.last_date)}</td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </c:when>

            <c:otherwise>
                <div class="overflow-x-auto">
                    <table class="[:where(&)]:min-w-full table-fixed border-separate border-spacing-0 isolate text-zinc-800 dark:text-zinc-200 whitespace-nowrap" data-flux-table>
                        <thead>
                            <tr class="text-xs font-semibold uppercase tracking-wider text-zinc-500 border-b border-zinc-200 dark:border-zinc-700">
                                <th class="py-3 px-3 text-start">Tree Type</th>
                                <th class="py-3 px-3 text-start">Category</th>
                                <th class="py-3 px-3 text-start">Harvest Events</th>
                                <th class="py-3 px-3 text-end">Total Yield</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-zinc-100 dark:divide-zinc-800 text-sm">
                            <c:forEach var="row" items="${harvestRows}">
                                <tr class="hover:bg-zinc-50 dark:hover:bg-zinc-800/50">
                                    <td class="py-3 px-3 font-semibold text-zinc-900 dark:text-white">${h:e(row.type_name)}</td>
                                    <td class="py-3 px-3">
                                        <span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-zinc-100 text-zinc-800 dark:bg-zinc-800 dark:text-zinc-200">
                                            ${h:e(row.category_name)}
                                        </span>
                                    </td>
                                    <td class="py-3 px-3 text-zinc-600 dark:text-zinc-400">${row.harvest_count} records</td>
                                    <td class="py-3 px-3 text-end font-semibold text-zinc-900 dark:text-white">${h:number(row.total_quantity)} ${h:e(row.unit)}</td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</ui:layout>
