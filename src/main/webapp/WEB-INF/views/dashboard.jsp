<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="h" uri="https://harvesta.app/functions" %>

<ui:layout title="Dashboard" active="dashboard" charts="true">
    <ui:header title="Dashboard" description="Overview of trees, care tasks, harvests, and financials." />

    <!-- Top Statistics Grid -->
    <div class="grid grid-cols-1 gap-4 sm:grid-cols-2 xl:grid-cols-4 mb-6">
        <!-- Total Trees Card -->
        <div class="rounded-xl border border-zinc-200 bg-white p-5 shadow-xs dark:border-zinc-700 dark:bg-zinc-900">
            <div class="flex items-center justify-between">
                <span class="text-xs font-semibold uppercase tracking-wider text-zinc-500 dark:text-zinc-400">Total Trees</span>
                <span class="p-2 rounded-lg bg-green-50 text-green-700 dark:bg-green-950/50 dark:text-green-300">
                    ${h:icon('tree')}
                </span>
            </div>
            <div class="mt-2 flex items-baseline gap-2">
                <span class="text-2xl font-bold tracking-tight text-zinc-900 dark:text-white">${totalTrees}</span>
                <span class="text-xs text-zinc-500">planted trees</span>
            </div>
            <div class="mt-3 flex flex-wrap gap-1">
                <span class="inline-flex items-center text-[11px] font-medium px-1.5 py-0.5 rounded bg-green-100 text-green-800 dark:bg-green-900/40 dark:text-green-300">
                    ${treesByStatus.getOrDefault('productive', 0)} productive
                </span>
                <span class="inline-flex items-center text-[11px] font-medium px-1.5 py-0.5 rounded bg-lime-100 text-lime-800 dark:bg-lime-900/40 dark:text-lime-300">
                    ${treesByStatus.getOrDefault('growing', 0)} growing
                </span>
                <span class="inline-flex items-center text-[11px] font-medium px-1.5 py-0.5 rounded bg-blue-100 text-blue-800 dark:bg-blue-900/40 dark:text-blue-300">
                    ${treesByStatus.getOrDefault('seedling', 0)} seedling
                </span>
            </div>
        </div>

        <!-- Total Blocks Card -->
        <div class="rounded-xl border border-zinc-200 bg-white p-5 shadow-xs dark:border-zinc-700 dark:bg-zinc-900">
            <div class="flex items-center justify-between">
                <span class="text-xs font-semibold uppercase tracking-wider text-zinc-500 dark:text-zinc-400">Total Blocks</span>
                <span class="p-2 rounded-lg bg-emerald-50 text-emerald-700 dark:bg-emerald-950/50 dark:text-emerald-300">
                    ${h:icon('blocks')}
                </span>
            </div>
            <div class="mt-2 flex items-baseline gap-2">
                <span class="text-2xl font-bold tracking-tight text-zinc-900 dark:text-white">${totalBlocks}</span>
                <span class="text-xs text-zinc-500">planting areas</span>
            </div>
            <p class="mt-3 text-xs text-zinc-500 dark:text-zinc-400">Across entire farm land</p>
        </div>

        <!-- Monthly Harvest Card -->
        <div class="rounded-xl border border-zinc-200 bg-white p-5 shadow-xs dark:border-zinc-700 dark:bg-zinc-900">
            <div class="flex items-center justify-between">
                <span class="text-xs font-semibold uppercase tracking-wider text-zinc-500 dark:text-zinc-400">Harvest This Month</span>
                <span class="p-2 rounded-lg bg-amber-50 text-amber-700 dark:bg-amber-950/50 dark:text-amber-300">
                    ${h:icon('harvests')}
                </span>
            </div>
            <div class="mt-2 flex items-baseline gap-2">
                <span class="text-2xl font-bold tracking-tight text-zinc-900 dark:text-white">${h:number(kgThisMonth)}</span>
                <span class="text-xs text-zinc-500">kg</span>
            </div>
            <p class="mt-3 text-xs text-zinc-500 dark:text-zinc-400">Plus ${h:number(pcsThisMonth)} pcs harvested</p>
        </div>

        <!-- Net Profit Card (Admin) or Activity Card (Staff) -->
        <c:choose>
            <c:when test="${isAdmin}">
                <div class="rounded-xl border border-zinc-200 bg-white p-5 shadow-xs dark:border-zinc-700 dark:bg-zinc-900">
                    <div class="flex items-center justify-between">
                        <span class="text-xs font-semibold uppercase tracking-wider text-zinc-500 dark:text-zinc-400">Net Profit (Month)</span>
                        <span class="p-2 rounded-lg bg-emerald-50 text-emerald-700 dark:bg-emerald-950/50 dark:text-emerald-300">
                            ${h:icon('sales')}
                        </span>
                    </div>
                    <div class="mt-2 flex items-baseline gap-2">
                        <span class="text-xl font-bold tracking-tight ${netProfitThisMonth >= 0 ? 'text-green-700 dark:text-green-400' : 'text-red-700 dark:text-red-400'}">
                            ${h:money(netProfitThisMonth)}
                        </span>
                    </div>
                    <p class="mt-3 text-xs text-zinc-500 dark:text-zinc-400">Sales: ${h:money(salesThisMonth)} · Exp: ${h:money(expensesThisMonth)}</p>
                </div>
            </c:when>
            <c:otherwise>
                <div class="rounded-xl border border-zinc-200 bg-white p-5 shadow-xs dark:border-zinc-700 dark:bg-zinc-900">
                    <div class="flex items-center justify-between">
                        <span class="text-xs font-semibold uppercase tracking-wider text-zinc-500 dark:text-zinc-400">Needs Attention</span>
                        <span class="p-2 rounded-lg bg-yellow-50 text-yellow-700 dark:bg-yellow-950/50 dark:text-yellow-300">
                            ${h:icon('care-logs')}
                        </span>
                    </div>
                    <div class="mt-2 flex items-baseline gap-2">
                        <span class="text-2xl font-bold tracking-tight text-zinc-900 dark:text-white">${treesByStatus.getOrDefault('needs_attention', 0)}</span>
                        <span class="text-xs text-zinc-500">trees</span>
                    </div>
                    <p class="mt-3 text-xs text-zinc-500 dark:text-zinc-400">Requires treatment or pest inspection</p>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

    <!-- Middle Tables Grid: Upcoming Care & Recent Harvests -->
    <div class="grid grid-cols-1 xl:grid-cols-2 gap-6 mb-6">
        <!-- Upcoming Care Table -->
        <div class="rounded-xl border border-zinc-200 bg-white p-5 shadow-xs dark:border-zinc-700 dark:bg-zinc-900">
            <div class="flex items-center justify-between mb-4">
                <h2 class="text-base font-semibold text-zinc-800 dark:text-white">Upcoming Care Tasks</h2>
                <a href="${pageContext.request.contextPath}/care-logs" class="text-xs font-medium text-[var(--color-accent-content)] hover:underline">View all</a>
            </div>
            <c:choose>
                <c:when test="${not empty upcomingCare}">
                    <div class="overflow-x-auto">
                        <table class="w-full table-fixed text-left text-xs divide-y divide-zinc-200 dark:divide-zinc-700" style="min-width: 28rem">
                            <colgroup>
                                <col style="width: 24%">
                                <col style="width: 48%">
                                <col style="width: 28%">
                            </colgroup>
                            <thead>
                                <tr class="font-semibold text-zinc-500 uppercase tracking-wider">
                                    <th class="px-2 pb-2 whitespace-nowrap">Tree</th>
                                    <th class="px-2 pb-2 whitespace-nowrap">Activity</th>
                                    <th class="px-2 pb-2 text-end whitespace-nowrap">Due Date</th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-zinc-100 dark:divide-zinc-800">
                                <c:forEach var="c" items="${upcomingCare}">
                                    <tr>
                                        <td class="px-2 py-2 font-medium text-zinc-900 dark:text-white whitespace-nowrap">
                                            <a href="${pageContext.request.contextPath}/trees/${c.tree_id}" class="hover:underline text-[var(--color-accent-content)]">${h:e(c.tree_code)}</a>
                                        </td>
                                        <td class="px-2 py-2 text-zinc-600 dark:text-zinc-300 whitespace-nowrap">${h:label(c.activity_type)}</td>
                                        <td class="px-2 py-2 text-end text-zinc-500 dark:text-zinc-400 whitespace-nowrap">${h:date(c.next_due_on)}</td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:when>
                <c:otherwise>
                    <p class="text-sm text-zinc-500 py-4 text-center">No upcoming tasks due soon.</p>
                </c:otherwise>
            </c:choose>
        </div>

        <!-- Recent Harvests Table -->
        <div class="rounded-xl border border-zinc-200 bg-white p-5 shadow-xs dark:border-zinc-700 dark:bg-zinc-900">
            <div class="flex items-center justify-between mb-4">
                <h2 class="text-base font-semibold text-zinc-800 dark:text-white">Recent Harvests</h2>
                <a href="${pageContext.request.contextPath}/harvests" class="text-xs font-medium text-[var(--color-accent-content)] hover:underline">View all</a>
            </div>
            <c:choose>
                <c:when test="${not empty recentHarvests}">
                    <div class="overflow-x-auto">
                        <table class="w-full table-fixed text-left text-xs divide-y divide-zinc-200 dark:divide-zinc-700" style="min-width: 28rem">
                            <colgroup>
                                <col style="width: 22%">
                                <col style="width: 22%">
                                <col style="width: 28%">
                                <col style="width: 28%">
                            </colgroup>
                            <thead>
                                <tr class="font-semibold text-zinc-500 uppercase tracking-wider">
                                    <th class="px-2 pb-2 whitespace-nowrap">Tree</th>
                                    <th class="px-2 pb-2 whitespace-nowrap">Quantity</th>
                                    <th class="px-2 pb-2 whitespace-nowrap">Grade</th>
                                    <th class="px-2 pb-2 text-end whitespace-nowrap">Date</th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-zinc-100 dark:divide-zinc-800">
                                <c:forEach var="hItem" items="${recentHarvests}">
                                    <tr>
                                        <td class="px-2 py-2 font-medium text-zinc-900 dark:text-white whitespace-nowrap">
                                            <a href="${pageContext.request.contextPath}/trees/${hItem.tree_id}" class="hover:underline text-[var(--color-accent-content)]">${h:e(hItem.tree_code)}</a>
                                        </td>
                                        <td class="px-2 py-2 text-zinc-600 dark:text-zinc-300 whitespace-nowrap">${h:number(hItem.quantity)} ${h:e(hItem.unit)}</td>
                                        <td class="px-2 py-2 whitespace-nowrap">
                                            <span class="inline-flex items-center rounded px-1.5 py-0.5 font-medium bg-zinc-100 text-zinc-800 dark:bg-zinc-800 dark:text-zinc-200">
                                                ${h:label(hItem.grade)}
                                            </span>
                                        </td>
                                        <td class="px-2 py-2 text-end text-zinc-500 dark:text-zinc-400 whitespace-nowrap">${h:date(hItem.harvested_on)}</td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:when>
                <c:otherwise>
                    <p class="text-sm text-zinc-500 py-4 text-center">No recent harvests recorded.</p>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <!-- Charts Section -->
    <div class="grid grid-cols-1 ${isAdmin ? 'xl:grid-cols-2' : ''} gap-6">
        <!-- 12-Month Harvest Chart -->
        <div class="rounded-xl border border-zinc-200 bg-white p-5 shadow-xs dark:border-zinc-700 dark:bg-zinc-900">
            <h2 class="text-base font-semibold text-zinc-800 dark:text-white mb-4">Harvest History (12 Months)</h2>
            <div class="relative h-64 w-full">
                <canvas id="harvestChart"></canvas>
            </div>
        </div>

        <!-- 12-Month Financial Chart (Admin only) -->
        <c:if test="${isAdmin}">
            <div class="rounded-xl border border-zinc-200 bg-white p-5 shadow-xs dark:border-zinc-700 dark:bg-zinc-900">
                <h2 class="text-base font-semibold text-zinc-800 dark:text-white mb-4">Sales vs. Expenses (12 Months)</h2>
                <div class="relative h-64 w-full">
                    <canvas id="financialChart"></canvas>
                </div>
            </div>
        </c:if>
    </div>

    <script>
    document.addEventListener("DOMContentLoaded", function () {
        // Harvest Chart
        var ctxH = document.getElementById('harvestChart');
        if (ctxH) {
            new Chart(ctxH, {
                type: 'bar',
                data: {
                    labels: [
                        <c:forEach var="m" items="${chartMonths}" varStatus="loop">
                            '${m}'${!loop.last ? ',' : ''}
                        </c:forEach>
                    ],
                    datasets: [{
                        label: 'Harvest (kg)',
                        data: [
                            <c:forEach var="hVal" items="${chartHarvests}" varStatus="loop">
                                ${hVal}${!loop.last ? ',' : ''}
                            </c:forEach>
                        ],
                        backgroundColor: '#2F7D4F',
                        borderRadius: 4
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: { legend: { display: false } },
                    scales: {
                        y: { beginAtZero: true, grid: { color: 'rgba(0,0,0,0.05)' } },
                        x: { grid: { display: false } }
                    }
                }
            });
        }

        // Financial Chart
        var ctxF = document.getElementById('financialChart');
        if (ctxF) {
            new Chart(ctxF, {
                type: 'line',
                data: {
                    labels: [
                        <c:forEach var="m" items="${chartMonths}" varStatus="loop">
                            '${m}'${!loop.last ? ',' : ''}
                        </c:forEach>
                    ],
                    datasets: [
                        {
                            label: 'Sales (IDR)',
                            data: [
                                <c:forEach var="sVal" items="${chartSales}" varStatus="loop">
                                    ${sVal}${!loop.last ? ',' : ''}
                                </c:forEach>
                            ],
                            borderColor: '#2F7D4F',
                            backgroundColor: 'rgba(47, 125, 79, 0.1)',
                            fill: true,
                            tension: 0.3
                        },
                        {
                            label: 'Expenses (IDR)',
                            data: [
                                <c:forEach var="eVal" items="${chartExpenses}" varStatus="loop">
                                    ${eVal}${!loop.last ? ',' : ''}
                                </c:forEach>
                            ],
                            borderColor: '#DC2626',
                            backgroundColor: 'rgba(220, 38, 38, 0.1)',
                            fill: true,
                            tension: 0.3
                        }
                    ]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    scales: {
                        y: { beginAtZero: true, grid: { color: 'rgba(0,0,0,0.05)' } },
                        x: { grid: { display: false } }
                    }
                }
            });
        }
    });
    </script>
</ui:layout>
